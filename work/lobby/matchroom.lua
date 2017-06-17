local skynet = require "skynet"
require "skynet.manager"
local config = require "config.lobbyConfig"

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

local CMD 		= {}

function CMD.matchReq(fd,req)
	logger.common.error("getTransReq");
    local resp = {
        errorCode = 0,
        ip = "",
        port =0,
    }

    local addr = skynet.call(".serverlobby", "lua", "gettrans")
    if addr == nil then
        resp.errorCode = errorcode.getlobbyaddrfail
    else
        resp.ip = addr.ip
        resp.port = addr.port
    end
    response(fd,pbCode.msg.getTransReq,resp)
end

function CMD.start(service)
	skynet.register(".matchroom")
end

skynet.start(function()
	skynet.dispatch("lua", function( session, source, command, ... )
		local f = CMD[command]
        if f then
            skynet.ret(skynet.pack(f(...)))
        end
	end)
end)


