local skynet 		= require "skynet"
local gateserver 	= require "snax.gateserver"
local socketdriver 	= require "socketdriver"
local md5 			= require "md5"

local protobuf      = require "protobuf"
local pbCode        = require "workcommon/pb/pbCode"
local errorcode     = require "workcommon/macro/errorcode"
local logger 		= require "common.log.commonlog"


--加载pb
local pbFile
pbFile = io.open("work/workcommon/pb/msg.pb", "rb")
protobuf.register(pbFile:read("*a"))
pbFile:close()

local function closefd(fd)
    gateserver.closeclient(fd)  		-- 关闭 fd
end

local function response(fd,msgID,resp)
    local respId = pbCode.getRepToRespID(msgID)
    local pbmessage = pbCode.getPBStrByMsgID(respId)
    local msg = protobuf.encode(pbmessage , resp)
    local packet = string.pack(">s2", string.pack("<I4", respId)..msg)
    socketdriver.send(fd, packet)
    closefd(fd)
end


local dealCmd = {}
dealCmd[pbCode.msg.loginReq] = function(fd, req )

    logger.common.error("deviceid :"..req.deviceid);
    logger.common.error("userid :".. (req.userid or 0 ));
    local resp = {
        errorCode = 0,
        ip = "",
        port =0,
    }

    local addr = skynet.call(".getlobby", "lua", "getlobby")
    if addr == nil then
        resp.errorCode = errorcode.getlobbyaddrfail
    else
        resp.ip = addr.ip
        resp.port = addr.port
    end
    response(fd,pbCode.msg.loginReq,resp)
end


local CMD = {}
CMD.message = function (fd, packet )
	local msgId = string.unpack("<I4", packet)
    local msg = string.sub(packet, 5)

    local pbmessage = pbCode.getPBStrByMsgID(msgId)
    local req, errormsg = protobuf.decode(pbmessage, msg)
    if req == nil then
        logger.common.error("protobuf.decode error :"..errormsg)
        return
    end
    
    local f = dealCmd[msgId]
    if f then
    	f(fd,req)
	else
		logger.common.error("msgId is error :"..msgId);
        closefd(fd)
	end
end


local handler = {}
function handler.open(source, conf)
end
function handler.connect(fd, addr)
    gateserver.openclient(fd)   		-- 允许 fd 接收消息
end
function handler.disconnect(fd)
    closefd(fd)
end
function handler.error(fd, msg)
    closefd(fd)
end
function handler.message(fd, msg, sz)	--处理网络包
    local packet = skynet.tostring(msg, sz)
    CMD.message(fd, packet)
end

function handler.command(cmd, source, ...)
end

gateserver.start(handler)

