local skynet        = require "skynet"
local gateserver    = require "snax.gateserver"
local socketdriver  = require "socketdriver"
local md5           = require "md5"
local netpack   = require "netpack"

local protobuf      = require "protobuf"
local pbCode        = require "workcommon/pb/pbCode"
local errorcode     = require "workcommon/macro/errorcode"
local logger        = require "common.log.commonlog"
local redisAccount = require "workcommon.db.redis.account"

local roomservice = require "lobby.control.roomservice"


--加载pb
local pbFile
pbFile = io.open("work/workcommon/pb/msg.pb", "rb")
protobuf.register(pbFile:read("*a"))
pbFile:close()

local dealCmd = {}
local handler = {}
local CMD = {}



-------------------------------------------------------------------------------------

local function registerService( service )
    for k, v in pairs(service.getCmd()) do
        dealCmd[k] = v
    end
end

-------------------------------------------------------------------------------------
local function closefd(fd)
    gateserver.closeclient(fd)          -- 关闭 fd
end

function handler.open(source, conf)
    registerService()
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
    local packet = netpack.tostring(msg, sz)
    CMD.message(fd, packet)
end

function handler.command(cmd, source, ...)
    local f = CMD[command]
    if f then
        skynet.ret(skynet.pack(f(...)))
    end
end

gateserver.start(handler)

-------------------------------------------------------------------------------------


CMD.timeoutClosefd = function ()
    -- local t = skynet.now()
    -- local interval = 100 * 1 * 60 
    -- local tb = {}
    -- for k,v in pairs(g_connect) do
    --     if (t-v) > interval then
    --         table.insert(tb,k)
    --     end
    -- end
    -- for i,v in ipairs(tb) do
    --     closefd(v)
    -- end
end
CMD.message = function (fd, packet )
    local msgId = string.unpack("<I4", packet)
    local msg = string.sub(packet, 5)

    local pbmessage = pbCode.getPBStrByMsgID(msgId)
    if pbmessage == nil then
        logger.common.error("not find msgId :"..msgId);
        return
    end

    local req, errormsg = protobuf.decode(pbmessage, msg)
    if req == nil then
        logger.common.error("protobuf.decode error :"..errormsg)
        return
    end
    
    if msgId == pbCode.msg.loginLobbyReq then
        dealLogin(fd,msgId,req)
    else
        --这里判断有没有登录
        --并获取role
        deal(fd,msgId,req,role)
    end
end

-------------------------------------------------------------------------------------
local function response(fd,msgId,resp)
    local respId = pbCode.getRepToRespID(msgId)
    local pbmessage = pbCode.getPBStrByMsgID(respId)
    local msg = protobuf.encode(pbmessage , resp)
    local packet = string.pack(">s2", string.pack("<I4", respId)..msg)
    socketdriver.send(fd, packet)
end
local function dealLogin( fd,msgId,req )
    local resp = {errorCode = 0}

    local passwd = redisAccount.getUserPassword(req.userid)
    if passwd == req.password then
        --
    else
        resp.errorCode = errorcode.loginlobbyfail
    end
    response(fd,pbCode.msg.loginLobbyReq,resp)
end

local function deal( fd,msgId,req,role )
    local f = dealCmd[msgId]
    if f then
        local start_time = skynet.now()
        local reply = function(resp)
            response(fd,msgId,resp)
            local diff_time = skynet.now()-start_time
            if difftime >= 1 then
                logger.common.info("fd:%d,userid:%d msgid:%d dealtime:%d", fd,role.userid,msgId, difftime)
            end
        end
        xpcall(f, 
            function(errormsg)
                logger.common.error("userid:%d, msgId:%d error_msg:%s", role.userid, msgId, debug.traceback(errormsg, 2))
            end, 
            reply, 
            role, 
            req)

    else
        logger.common.info("fd:%d,userid:%d not_this_msgid:%d ", fd,role.userid, msgId)
    end
end
