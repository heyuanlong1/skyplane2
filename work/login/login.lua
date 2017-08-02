local skynet 		= require "skynet"
local gateserver 	= require "snax.gateserver"
local socketdriver 	= require "socketdriver"
local md5 			= require "md5"
local netpack   = require "netpack"
local protobuf      = require "protobuf"
local pbCode        = require "workcommon/pb/pbCode"
local errorcode     = require "workcommon/macro/errorcode"
local logger        = require "common.log.commonlog"
local utils 		= require "common.tools.utils"
local redisAccount = require "workcommon.db.redis.account"

--加载pb
local pbFile
pbFile = io.open("work/workcommon/pb/msg.pb", "rb")
protobuf.register(pbFile:read("*a"))
pbFile:close()

local dealCmd = {}
local handler = {}
local CMD = {}
local g_connect = {} -- fd -> time


-------------------------------------------------------------------------------------

local function closefd(fd)
    gateserver.closeclient(fd)          -- 关闭 fd
    g_connect.fd = nil
end
function handler.open(source, conf)
end
function handler.connect(fd, addr)
    gateserver.openclient(fd)   		-- 允许 fd 接收消息
    g_connect.fd = skynet.now()
end
function handler.disconnect(fd)
    closefd(fd)
end
function handler.error(fd, msg)
    closefd(fd)
end
function handler.message(fd, msg, sz)	--处理网络包
    local packet = netpack.tostring(msg, sz)
    CMD.message(fd, packet)
end

function handler.command(cmd, source, ...)
    local f = CMD[cmd]
    if f then
        skynet.ret(skynet.pack(f(...)))
    end
end

gateserver.start(handler)

-------------------------------------------------------------------------------------

CMD.timeoutClosefd = function ()
    logger.common.info("login_timeout_fd")
    local t = skynet.now()
    local interval = 100 * 1 * 60 
    local tb = {}
    for k,v in pairs(g_connect) do
        if (t-v) > interval then
            table.insert(tb,k)
        end
    end
    for i,v in ipairs(tb) do
        closefd(v)
    end
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
    
    local f = dealCmd[msgId]
    if f then
        f(fd,req)
    else
        logger.common.error("msgId is error :"..msgId);
        closefd(fd)
    end
end

-------------------------------------------------------------------------------------

local function response(fd,msgID,resp)
    local respId = pbCode.getRepToRespID(msgID)
    local pbmessage = pbCode.getPBStrByMsgID(respId)
    local msg = protobuf.encode(pbmessage , resp)
    local packet = string.pack(">s2", string.pack("<I4", respId)..msg)
    socketdriver.send(fd, packet)
    --closefd(fd)   --socket不应该无错误的主动断掉，应客户端主动关闭，服务器定时处理
end



dealCmd[pbCode.msg.regReq] = function(fd, req )
    logger.common.info("deviceid :"..req.deviceid);
    --先从数据库判断有没有注册过。

    local userid = redisAccount.getNextUserid()
    local passwd = utils.getRandomString(32)
    logger.common.info("userid :"..userid);
    logger.common.info("passwd :"..passwd);
    local resp = {
        errorCode = 0,
        userid = userid,
        password =passwd,
    }
    --存数据库表示注册了
    response(fd,pbCode.msg.regReq,resp)
end

dealCmd[pbCode.msg.loginReq] = function(fd, req )
    --未做重复登录的判断
    --取数据库判断是否注册过
    logger.common.info("userid :"..req.userid)
    logger.common.info("password :".. req.password)
    local resp = {
        errorCode = 0,
        lobbyip = "",
        lobbyport =0,
    }

    local addr = skynet.call(".getlobby", "lua", "getlobby")
    if addr == nil then
        resp.errorCode = errorcode.getlobbyaddrfail
    else
        resp.lobbyip = addr.ip
        resp.lobbyport = addr.port
    end
    --存redis表示登录了
    redisAccount.setUserLogin(req.userid,req.password)
    response(fd,pbCode.msg.loginReq,resp)
end







-------------------------------------------------------------------------------------