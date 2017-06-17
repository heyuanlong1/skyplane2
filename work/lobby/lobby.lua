local skynet        = require "skynet"
local gateserver    = require "snax.gateserver"
local socketdriver  = require "socketdriver"
local md5           = require "md5"

local protobuf      = require "protobuf"
local pbCode        = require "workcommon/pb/pbCode"
local errorcode     = require "workcommon/macro/errorcode"
local logger        = require "common.log.commonlog"


--加载pb
local pbFile
pbFile = io.open("work/workcommon/pb/msg.pb", "rb")
protobuf.register(pbFile:read("*a"))
pbFile:close()

local function closefd(fd)
    gateserver.closeclient(fd)          -- 关闭 fd
end

local function response(fd,msgID,resp)
    local respId = pbCode.getRepToRespID(msgID)
    local pbmessage = pbCode.getPBStrByMsgID(respId)
    local msg = protobuf.encode(pbmessage , resp)
    local packet = string.pack(">s2", string.pack("<I4", respId)..msg)
    socketdriver.send(fd, packet)
end


local CMD = {}
CMD.message = function (fd, packet )
    local msgId = string.unpack("<I4", packet)
    local msg = string.sub(packet, 5)

    local pbmessage = pbCode.getPBStrByMsgID(msgId)
    if pbmessage == nil then
        logger.common.error("not find msgId :"..msgId);
    end

    local req, errormsg = protobuf.decode(pbmessage, msg)
    if req == nil then
        logger.common.error("protobuf.decode error :"..errormsg)
        return
    end
    
    if msgId ==  pbCode.msg.getTransReq then
        skynet.call(".matchroom","lua","matchReq",fd,req)
    else
        logger.common.error("not deal msgId :"..msgId);
    end
end


local handler = {}
function handler.open(source, conf)
end
function handler.connect(fd, addr)
    gateserver.openclient(fd)           -- 允许 fd 接收消息
end
function handler.disconnect(fd)
    closefd(fd)
end
function handler.error(fd, msg)
    closefd(fd)
end
function handler.message(fd, msg, sz)   --处理网络包
    local packet = skynet.tostring(msg, sz)
    CMD.message(fd, packet)
end

function handler.command(cmd, source, ...)
end

gateserver.start(handler)

