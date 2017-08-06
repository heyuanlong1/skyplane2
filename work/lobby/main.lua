local skynet = require "skynet"
local config = require "config.lobbyConfig"
local redisdb = require "common.db.redis.redisdb"
local mysqldb = require "common.db.mysql.mysqldb"
local logger = require "common.log.commonlog"
local redisLauncher = require "workcommon.db.redis.launcher"

skynet.start(function()
    
    local serverlobby = skynet.newservice("serverlobby")
    skynet.call(serverlobby, "lua", "start")

    redisLauncher.launchAccount(config.redis.account.host,config.redis.account.port,config.redis.account.auth)

    local lobby = skynet.newservice("lobby")
    skynet.name(".lobby", lobby)
    skynet.call(lobby, "lua", "open", {
        port = config.server.port,
        maxclient = 10000,
        nodelay = true,
    })

	logger.common.info("start lobby")
    skynet.exit()
end)
