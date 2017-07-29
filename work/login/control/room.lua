local service = {}
local skynet = require "skynetExt"
local msgDef = require "network.protoBufMsgDef"
local friendConfig = require "app.config.server.friendConfig"
local rpcEnum = require "network.rpcEnum"

local itemHelper = require "agent.model.itemHelper"
local stat = require "db.mysql.stat"
local redisPlayer = require "db.redis.player"
local redisAccount = require "db.redis.account"
local loggers = require "gameserverLoggers"
local timeHelper = require "timeHelper"
local cityHelper = require "agent.model.cityHelper"
local CMD = {}



-- 请求邮件
CMD[msgDef.clientToServerMsg.getMailRequest] = function (reply, role, msg)
    
    local resp = {}
    resp.errorCode = rpcEnum.errorCode.SUCCESS
    resp.mail = {}

    local wmails = redisAccount.wgetAllMails()          --把全服邮件转为个人邮件
    for i, mail in ipairs(wmails) do
        if not role.m_moduleData.wmail[mail.id] then
            redisPlayer.sendMail(role.m_accountId, mail.type, mail.content, mail.time)
            role.m_moduleData.wmail[mail.id] = true
        end
    end

	
    local mails = redisPlayer.getAllMails(role.m_accountId)
	for i, mail in ipairs(mails) do
        local mailInfo =
        {
            mailId = mail.id,
            time = mail.time,
            type = mail.type,
        }
        if mail.type == rpcEnum.mailType.addFriend or
            mail.type == rpcEnum.mailType.askForStrength or
            mail.type == rpcEnum.mailType.giveStrength then

            mailInfo.playerInfo = mail.content.playerInfo

        elseif mail.type == rpcEnum.mailType.gm then
            mailInfo.content = mail.content.content
            mailInfo.showItems = mail.content.items
        end
        table.insert(resp.mail, mailInfo)
    end


    reply(resp)

end

procMailFunc = {}
-- 注册邮件处理函数
function resgisterMailProcFunc(mailType, clientResult, func)
	if not procMailFunc[clientResult] then
		procMailFunc[clientResult] = {}
	end
	procMailFunc[clientResult][mailType] = func
end

-- 默认的空处理函数
function defaultMailProcFunc(role, content, attachments)
	return true
end

-- 同意添加好友
function onAgreeAddFriend(role, content, attachments)
    local friendId = content.playerInfo.accountId
    local followings, followingNum, isFollowing = redisPlayer.getFollowings(role.m_accountId)
    if not isFollowing(friendId) and  followingNum < friendConfig.maxFriendCount then
        redisPlayer.addFollowing(role.m_accountId, friendId)
    end
    return true
end

-- 同意求助体力
function onAgreeAskForStrength(role, content, attachments)
    local friendId = content.playerInfo.accountId
    
	redisPlayer.sendMail(friendId, rpcEnum.mailType.giveStrength, {
        playerInfo =
        {
            accountId = role.m_accountId,
            nickname = role.m_nickname,
            headImage = role.m_headImage,
            maxPassedLevelId = role:getMaxPassedLevelId(),
            totalStar = role:getTotalStar(),
            totalCityProgress = cityHelper.getTotalCityProgress(role),
        },
    })
    
    
    --只有双向好友才加好友度
    local followers, followerNum, isFollower = redisPlayer.getFollowers(role.m_accountId)
    local newValue = 0
    if isFollower(friendId) then
        newValue = redisPlayer.increaseFriendValue(role.m_accountId, friendId, friendConfig.friendValueOfGiveStrength)
        redisPlayer.increaseFriendValue(friendId, role.m_accountId, friendConfig.friendValueOfGiveStrength)
    end
    

    stat.logInteraction(role.m_baseInfo, content.playerInfo.accountId, rpcEnum.interactionEvent.giveStrength, newValue)
	return true
end

-- 同意收体力
function onAgreeGiveStrength(role, content, attachments)
    local today = timeHelper.getPassDay(skynet.utcTime())
    local lastDay = timeHelper.getPassDay(role.m_moduleData.friend.lastRecvStrengthTime) 
    --是否能接收体力
    if today > lastDay or
        role.m_moduleData.friend.hasRecvStrengthCount < friendConfig.maxRecvStrengthCount then	-- 今天还没收满

        table.insert(attachments, {itemId = friendConfig.recvStrengthItemId, count = 1})
        
        -- 记录收体力的次数
        if today > lastDay then
            role.m_moduleData.friend.hasRecvStrengthCount = 0
        end
    	role.m_moduleData.friend.lastRecvStrengthTime = skynet.utcTime()
    	role.m_moduleData.friend.hasRecvStrengthCount = role.m_moduleData.friend.hasRecvStrengthCount + 1

        return true
    else
        return false
	end
end

function onAgreeGmMail(role, content, attachments)
    for i, v in ipairs(content.items) do
        table.insert(attachments, {itemId = v.itemId, count = v.count})
    end
    return true
end

resgisterMailProcFunc(rpcEnum.mailType.addFriend, rpcEnum.mailClientOptCode.agree, onAgreeAddFriend)
resgisterMailProcFunc(rpcEnum.mailType.addFriend, rpcEnum.mailClientOptCode.refuse, defaultMailProcFunc)
resgisterMailProcFunc(rpcEnum.mailType.askForStrength, rpcEnum.mailClientOptCode.agree, onAgreeAskForStrength)
resgisterMailProcFunc(rpcEnum.mailType.askForStrength, rpcEnum.mailClientOptCode.refuse, defaultMailProcFunc)
resgisterMailProcFunc(rpcEnum.mailType.giveStrength, rpcEnum.mailClientOptCode.agree, onAgreeGiveStrength)
resgisterMailProcFunc(rpcEnum.mailType.giveStrength, rpcEnum.mailClientOptCode.refuse, defaultMailProcFunc)
resgisterMailProcFunc(rpcEnum.mailType.gm, rpcEnum.mailClientOptCode.agree, onAgreeGmMail)
resgisterMailProcFunc(rpcEnum.mailType.gm, rpcEnum.mailClientOptCode.refuse, defaultMailProcFunc)

-- 处理邮件
CMD[msgDef.clientToServerMsg.procMailRequest] = function (reply, role, msg)

    local attachments = {}
    
	for i, mailId in ipairs(msg.mailIds) do
		local mail = redisPlayer.getMail(role.m_accountId, mailId)
        if mail then
            local func = procMailFunc[msg.result][mail.type]
            if func(role, mail.content, attachments) then
                redisPlayer.deleteMail(role.m_accountId, mailId)
            end
        else
            loggers.sidong.info("redis找不到邮件%d, 帐号%d", mailId, role.m_accountId)
        end
	end

    local bagItems = itemHelper.newBagItems(role, attachments)
    itemHelper.receiveItems(role, rpcEnum.event.mail, bagItems)
	-- 回复客户端处理结果
	local resp = {
		errorCode   = rpcEnum.errorCode.SUCCESS,
		mailIds     = msg.mailIds,
		awardItems = bagItems,
	}
	reply(resp)
end

function service.getCmd()
    return CMD
end

function service.getMsgMap()
    return
    {
        [msgDef.clientToServerMsg.getMailRequest] = msgDef.clientToServerMsg.getMailResponse,
        [msgDef.clientToServerMsg.procMailRequest] = msgDef.clientToServerMsg.procMailResponse,
    }
end

return service