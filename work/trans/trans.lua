local skynet 		= require "skynet"
local gateserver 	= require "snax.gateserver"
local socketdriver 	= require "socketdriver"
local md5 			= require "md5"

local protobuf      = require "protobuf"
local pbCode        = require "pb/pbCode"
local logger 		= require "common.log.commonlog"


--加载pb
local pbFile
pbFile = io.open("work/pb/test.pb", "rb")
protobuf.register(pbFile:read("*a"))
pbFile:close()

local function closeFd(fd)
    gateserver.closeclient(fd)  		-- 关闭 fd
end

local function response(fd,msgID,resp)
    local respId = pbCode.getRepToResponseID(msgID)
    local pbmessage = pbCode.getProtoBuffStrByMsgID(respId)
    local msg = protobuf.encode(pbmessage , resp)
    local packet = string.pack(">s2", string.pack("<I4", respId)..msg)
    socketdriver.send(fd, packet)
    closeFd(fd)
end


local dealCmd = {}
dealCmd[pbCode.clientToServerMsg.wailiTestRegRequest] = function(fd, req )
    local authCode = md5.sumhexa( req.id.."_"..tostring(skynet.time()) )
    print("------- authCode:"..authCode)

    local resp = {
        errorCode = 200,
        authCode = authCode,
    }
    response(fd,pbCode.clientToServerMsg.wailiTestRegRequest,resp)
end


local CMD = {}
CMD.message = function (fd, packet )
	local msgId = string.unpack("<I4", packet)
    local msg = string.sub(packet, 5)

    local pbmessage = pbCode.getProtoBuffStrByMsgID(msgId)
    local req, errormsg = protobuf.decode(pbmessage, msg)

    local f = dealCmd[msgId]
    if f then
    	f(fd,req)
	else
		logger.common.error("msgId is error :"..msgId);
		--发送错误
	end
end


local handler = {}
function handler.open(source, conf)
end
function handler.connect(fd, addr)
    gateserver.openclient(fd)   		-- 允许 fd 接收消息
end
function handler.disconnect(fd)
    closeFd(fd)
end
function handler.error(fd, msg)
    closeFd(fd)
end
function handler.message(fd, msg, sz)	--处理网络包
    local packet = skynet.tostring(msg, sz)
    CMD.message(fd, packet)
end

function handler.command(cmd, source, ...)
end

gateserver.start(handler)

