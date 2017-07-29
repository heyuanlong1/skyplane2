local config = require "config.loginConfig"
local skynet = require "skynet"
local logger        = require "common.log.commonlog"

local m = {}
function m.launchAccount()
    skynet.call(skynet.newservice("redisdb"), "lua", "start", ".redis_account", {host=config.redis.account.host ,port=config.redis.account.port }, config.redis.account.auth, 4)
end


return m