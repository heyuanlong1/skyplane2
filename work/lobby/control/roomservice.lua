local skynet        = require "skynet"
local pbCode        = require "workcommon/pb/pbCode"
local errorcode     = require "workcommon/macro/errorcode"
local logger        = require "common.log.commonlog"
local redisAccount = require "workcommon.db.redis.account"

local service ={}
local CMD = {}

CMD[pbCode.msg.getRoomAddrReq] = function (reply, role, req)
    logger.common.info("getRoomAddrReq");

    local resp = {
        errorCode = 0,
    }
    local addr = skynet.call(".serverlobby", "lua", "gettrans")
    if addr == nil then
        resp.errorCode = errorcode.getroomaddrfail
    else
        resp.roomip = addr.ip
        resp.roomport = addr.port
    end

    reply(resp)
end


function service.getCmd()
    return CMD
end

return service