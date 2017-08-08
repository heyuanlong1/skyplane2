local skynet                = require "skynet"
require "skynet.manager"
local pbCode                = require "workcommon/pb/pbCode"
local errorcode             = require "workcommon/macro/errorcode"
local protobuf              = require "protobuf"
local logger                = require "common.log.commonlog"
local socketdriver          = require "socketdriver"
local utils                 = require "common.tools.utils"

local service ={}
local roomMap = {}
local CMD = {}


-------------------------------------------------------------------------------------
local ROOM_NOTSTART = false
local ROOM_START = true


local g_roomid = 0
function getRoomid( ) 
    g_roomid = g_roomid + 1  
    return g_roomid
end
local roomType = {
    pvp1                = 1,
    pvp2                = 2,
    pvp3                = 3,
    pvp4                = 4,
    pvproomid           = 1000,
}

local userMap = {}                  --userid -> {fd,roomType,roomid}
local roomMap = {}                  
for k,_ in pairs(roomType) do
    roomMap[k] = {}                 
end
-- {
--     roomType1 = {
--         roomid = { users = {users_list}},userNums,roomstatus},
--         roomid = { users = {users_list}},userNums,roomstatus},
--         roomid = { users = {users_list}},userNums,roomstatus},
--         ....
--     }
--     roomType2 = {
--         roomid = { users = {users_list}},userNums,roomstatus},
--         roomid = { users = {users_list}},userNums,roomstatus},
--         roomid = { users = {users_list}},userNums,roomstatus},
--         ....
--     }
-- }

local canInRoomMap = {}
for k,_ in pairs(roomType) do
    canInRoomMap[k] = {}                 
end
--     roomType1 = {
--         roomid = currnums,
--         roomid = currnums,
--         roomid = currnums,
--         ....
--     }
--     roomType2 = {
--         roomid = currnums,
--         roomid = currnums,
--         roomid = currnums,
--         ....
--     }
-- }

-------------------------------------------------------------------------------------
local function response(fd,msgId,resp)
    local respId = pbCode.getRepToRespID(msgId)
    local pbmessage = pbCode.getPBStrByMsgID(respId)
    local msg = protobuf.encode(pbmessage , resp)
    local packet = string.pack(">s2", string.pack("<I4", respId)..msg)
    socketdriver.send(fd, packet)
end


local function responsePacket(fd,packet)
    local p = string.pack(">s2", packet)
    socketdriver.send(fd, p)
end

-------------------------------------------------------------------------------------

CMD[pbCode.msg.matchReq] = function (reply, fd, req )
    local userid = req.userid
    logger.common.info("matchReq")
    local resp = {
     errorCode = 0,
     roomid  = 0,
     roomtype  = req.roomtype,
     owneruserid  = 0,
     nums= req.roomtype,
     currnums= 0,
     usersid = {},
     isstart= false,
    }

    local room_type = req.roomtype
    if roomType[room_type] == nil then
        resp.errorCode = errorcode.notroomtype
        reply(resp)

        logger.common.info("errorcode.notroomtype")
        return
    end
    logger.common.info("1111")

    local roomid = 0
    if room_type == "pvproomid" then
logger.common.info("45454")
    else
         logger.common.info("222222222")
        for k,v in pairs(canInRoomMap[room_type]) do
            logger.common.info("222"..k)
            roomid = k
            canInRoomMap[room_type][k] = canInRoomMap[room_type][k] + 1
            if canInRoomMap[room_type][k] == roomType[room_type] then
                canInRoomMap[room_type][k] = nil
            end
            table.insert(roomMap[room_type][roomid].users,userid)
            roomMap[room_type][roomid].userNums = roomMap[room_type][roomid].userNums + 1
            break
        end
        logger.common.info("77777777777")
        if roomid == 0 then
            logger.common.info("8888888888")
            local rid =getRoomid()
            canInRoomMap[room_type][rid] = 1
            roomMap[room_type][rid] = {users = {userid},userNums = 1,roomstatus = ROOM_NOTSTART }
            roomid = rid
        end
    end

    logger.common.info("333")
    logger.common.info(userid.."ddddddd")
    userMap[userid]={}
    userMap[userid].fd = fd
    userMap[userid].roomtype = room_type
    userMap[userid].roomid = roomid

    logger.common.info("33344")
    resp.roomid = roomid
    logger.common.info("33344")
    resp.currnums = 0
    for k,v in pairs(roomMap[room_type][roomid].users) do
        resp.currnums = resp.currnums + 1
    end
    --resp.currnums = table.getn(roomMap[room_type][roomid].users)
    logger.common.info("33344")
    resp.usersid = roomMap[room_type][roomid].users
    resp.isstart = roomMap[room_type][roomid].roomstatus

    logger.common.info("8888888899999")
    for _,userid in ipairs( roomMap[room_type][roomid]["users"]) do
            logger.common.info("444")
            response(userMap[userid]["fd"],pbCode.msg.matchReq,resp)
    end

    logger.common.info("errorcode.0")
    reply(nil,req.userid)
    return 
end





CMD[pbCode.msg.startGameReq] = function (reply,fd, userid, req , _ )
    logger.common.info("startGameReq")
    local resp = {
     errorCode = 0,
     isstart= false,
    }

    logger.common.info(userid.."1")
    local room_type = userMap[userid].roomtype
    local roomid = req.roomid

    logger.common.info("2")
    if roomMap[room_type][roomid] == nil then
        resp.errorCode = errorcode.notroomid
        reply(resp)
        return
    end
    logger.common.info("3")
    if utils.isInList(userid,roomMap[room_type][roomid]["users"]) == false then
        resp.errorCode = errorcode.usernotinthisroom
        reply(resp)
        return
    end
    logger.common.info("4")
    roomMap[room_type][roomid].roomstatus = ROOM_START
    resp.isstart = true
 
    for _,uid in ipairs( roomMap[room_type][roomid]["users"]) do
            response(userMap[uid]["fd"],pbCode.msg.startGameReq,resp)
    end
    logger.common.info("5")
    reply(nil)
end


CMD[pbCode.msg.fightMsg] = function (reply,fd, userid, req, packet)
    logger.common.info("fightMsg");
    local resp = {errorCode = 0}

    logger.common.info("userid:%d",req.userid)
    logger.common.info("roomid:%d",req.roomid)
    logger.common.info("msg:%s",req.msg)

    local room_type = userMap[userid].roomtype
    local roomid = req.roomid

    logger.common.info("4")

    if roomMap[room_type][roomid] == nil then
        resp.errorCode = errorcode.notroomid
        reply(resp)
        return
    end

    logger.common.info("5")

    if utils.isInList(userid,roomMap[room_type][roomid]["users"]) == false then
        resp.errorCode = errorcode.usernotinthisroom
        reply(resp)
        return
    end
    logger.common.info("6")

 
    for _,uid in ipairs( roomMap[room_type][roomid]["users"]) do
            if uid ~= userid then
                responsePacket(userMap[uid]["fd"],packet)
            end
    end
    
    logger.common.info("7")
    reply(nil)
end


function service.getCmd()
    return CMD
end

return service