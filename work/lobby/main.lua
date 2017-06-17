local skynet = require "skynet"
local config = require "config.lobbyConfig"
local redisdb = require "common.db.redis.redisdb"
local mysqldb = require "common.db.mysql.mysqldb"
local logger = require "common.log.commonlog"


skynet.start(function()
    
    local serverlobby = skynet.newservice("serverlobby")
    skynet.call(serverlobby, "lua", "start")



    local lobby = skynet.newservice("lobby")
    skynet.call(lobby, "lua", "open", {
        port = config.server.port,
        maxclient = 10000,
        nodelay = true,
    })

    local matchroom = skynet.newservice("matchroom")
    skynet.call(matchroom, "lua", "start")

	logger.common.info("start lobby")
    skynet.exit()
end)
