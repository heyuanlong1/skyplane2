local skynet = require "skynet"
require "skynet.manager"
local config = require "config.loginConfig"
local redisLauncher = require "workcommon.db.redis.launcher"
local logger = require "common.log.commonlog"


skynet.start(function()
    
    local getlobby = skynet.newservice("getlobby")
    skynet.call(getlobby, "lua", "start")

    redisLauncher.launchAccount(config.redis.account.host,config.redis.account.port,config.redis.account.auth)

    local login = skynet.newservice("login")
    skynet.name(".login", login)
    skynet.call(login, "lua", "open", {
        port = config.server.port,
        maxclient = 10000,
        nodelay = true,
    })

    skynet.call(skynet.newservice("timeoutManager"), "lua", "start")

	logger.common.info("start login ok")
    skynet.exit()
end)
