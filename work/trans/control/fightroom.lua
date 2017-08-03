local skynet                = require "skynet"
require "skynet.manager"
local pbCode                = require "workcommon/pb/pbCode"
local errorcode             = require "workcommon/macro/errorcode"
local protobuf              = require "protobuf"
local logger                = require "common.log.commonlog"
local socketdriver          = require "socketdriver"
local utils                 = require "common.tools.utils"

local roomMap = {}
local CMD = {}


-------------------------------------------------------------------------------------
local ROOM_NOTSTART = 0
local ROOM_START = 1


local g_roomid = 0
function getRoomid( ) 
    g_roomid = g_roomid + 1  
    return g_roomid
end
local roomType = {
    pvp1                = 1
    pvp2                = 2
    pvp3                = 3
    pvp4                = 4
    pvproomid           = 1000
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

CMD[pbCode.msg.matchReq] = function (reply, fd,userid, req , _ )
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
        return 
    end

    local roomid = 0
    if room_type == roomType.pvproomid then

    else
        for k,v in pairs(canInRoomMap[room_type]) do
            roomid = k
            canInRoomMap[room_type][k] = canInRoomMap[room_type][k] + 1
            if canInRoomMap[room_type][k] == roomType[room_type] then
                canInRoomMap[room_type][k] = nil
            end
            table.insert(roomMap[roomid].users,usersid)
            roomMap[roomid].userNums = roomMap[roomid].userNums + 1
            break
        end
        if roomid == 0 then
            local rid =getRoomid()
            canInRoomMap[room_type][rid] = 1
            roomMap[room_type][rid] = {users = {userid},userNums = 1,roomstatus = ROOM_NOTSTART }
            roomid = rid
        end
    end

    userMap[userid].fd = fd
    userMap[userid].roomtype = room_type
    userMap[userid].roomid = roomid

    resp.roomid = roomid
    resp.currnums = table.getn(roomMap[room_type][roomid].users)
    resp.usersid = roomMap[room_type][roomid].users

    for _,userid in ipairs( roomMap[room_type][roomid]["users"]) do
            response(userMap[userid]["fd"],pbCode.msg.matchReq,resp)
    end
    reply(nil)
end





CMD[pbCode.msg.startGameReq] = function (reply,fd, userid, req , _ )
    logger.common.info("startGameReq")
    local resp = {
     errorCode = 0,
     isstart= false,
    }

    local room_type = userMap[userid].roomtype
    local roomid = req.roomid
    if roomType[room_type] == nil then
        resp.errorCode = errorcode.notroomtype
        reply(resp)
        return 
    end
    if roomMap[room_type][roomid] == nil then
        resp.errorCode = errorcode.notroomid
        reply(resp)
        return
    end

    if utils.isInList(usersid,roomMap[room_type][roomid]["users"]) == false then
        resp.errorCode = errorcode.usernotinthisroom
        reply(resp)
        return
    end

    roomMap[roomid].roomstatus = ROOM_START
    resp.isstart = true
 
    for _,uid in ipairs( roomMap[room_type][roomid]["users"]) do
            response(userMap[uid]["fd"],pbCode.msg.startGameReq,resp)
    end
    reply(nil)
end




message fightMsg
{
    required int32 userid = 1;
    required int32 roomid = 2;
    required string msg = 3;
}

CMD[pbCode.msg.fightMsg] = function (reply,fd, userid, req, packet)
    logger.common.info("fightMsg");
    local resp = {errorCode = 0}

    local room_type = userMap[userid].roomtype
    local roomid = req.roomid
    if roomType[room_type] == nil then
        resp.errorCode = errorcode.notroomtype
        reply(resp)
        return 
    end
    if roomMap[room_type][roomid] == nil then
        resp.errorCode = errorcode.notroomid
        reply(resp)
        return
    end

    if utils.isInList(usersid,roomMap[room_type][roomid]["users"]) == false then
        resp.errorCode = errorcode.usernotinthisroom
        reply(resp)
        return
    end

 
    for _,uid in ipairs( roomMap[room_type][roomid]["users"]) do
            responsePacket(userMap[uid]["fd"],packet)
    end
    
    reply(nil)
end


function service.getCmd()
    return CMD
end

return service