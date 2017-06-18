local skynet = require "skynet"
require "skynet.manager"
local config = require "config.transConfig"

local socketdriver  = require "socketdriver"
local protobuf      = require "protobuf"
local pbCode        = require "workcommon/pb/pbCode"
local errorcode     = require "workcommon/macro/errorcode"
local logger        = require "common.log.commonlog"


--加载pb
local pbFile
pbFile = io.open("work/workcommon/pb/msg.pb", "rb")
protobuf.register(pbFile:read("*a"))
pbFile:close()

local function response(fd,msgID,resp)
    local respId = pbCode.getRepToRespID(msgID)
    local pbmessage = pbCode.getPBStrByMsgID(respId)
    local msg = protobuf.encode(pbmessage , resp)
    local packet = string.pack(">s2", string.pack("<I4", respId)..msg)
    socketdriver.send(fd, packet)
end
local function responsePacket(fd,packet)
    local p = string.pack(">s2", packet)
    socketdriver.send(fd, p)
end


local CMD 		= {}
function CMD.fightMsg(fd,req,packet,room)
	logger.common.info("fightMsg");

    for k,v in pairs(room) do
        if fd ~= v then
            responsePacket(v,packet)
        end
    end
end

function CMD.start(service)
	skynet.register(".fightroom")
end

skynet.start(function()
	skynet.dispatch("lua", function( session, source, command, ... )
		local f = CMD[command]
        if f then
            skynet.ret(skynet.pack(f(...)))
        end
	end)
end)


