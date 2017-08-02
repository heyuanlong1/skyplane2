local skynet                = require "skynet"
require "skynet.manager"
local pbCode                = require "workcommon/pb/pbCode"
local errorcode             = require "workcommon/macro/errorcode"
local protobuf              = require "protobuf"
local logger                = require "common.log.commonlog"
local socketdriver          = require "socketdriver"

local roomMap = {}
local CMD = {}


-------------------------------------------------------------------------------------
local roomType = {
    pvp1                = 1
    pvp2                = 2
    pvp3                = 3
    pvp4                = 4
    pvpN                = 11
    pvproomid           = 12
}

local userMap = {}                  --userid -> {fd,roomType,roomid}
local roomMap = {}                  
for _,v in pairs(roomType) do
    roomMap[v] = {}                 
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
for _,v in pairs(roomType) do
    canInRoomMap[v] = {}                 
end
--     roomType1 = {
--         roomid,
--         roomid,
--         roomid,
--         ....
--     }
--     roomType2 = {
--         roomid,
--         roomid,
--         roomid,
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

CMD[pbCode.msg.matchReq] = function (reply, userid, req)
    logger.common.info("matchReq")
    local resp = {}
    
    reply(resp)
end

CMD[pbCode.msg.fightMsg] = function (reply, userid, req, packet)
    logger.common.info("fightMsg");
    if userMap[userid]["roomid"] == req.roomid then
        local roomType = userMap[userid]["roomType"]
        local roomid   = req.roomid
        for _,userid in ipairs( roomMap[roomType][roomid]["users"]) do
            responsePacket(userMap[userid]["fd"],packet)
        end
    else
        logger.common.error("roomid error userMap[userid][\"roomid\"]=%d  req.roomid=%d",userMap[userid]["roomid"],req.roomid)
    end
    
    reply()
end


function service.getCmd()
    return CMD
end

return service