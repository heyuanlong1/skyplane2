local skynet = require "skynet"
require "skynet.manager"
local config = require "config.loginConfig"
local redisdb = require "common.db.redis.redisdb"
local mysqldb = require "common.db.mysql.mysqldb"
local logger = require "common.log.commonlog"


skynet.start(function()
    
    local getlobby = skynet.newservice("getlobby")
    skynet.call(getlobby, "lua", "start")

    local login = skynet.newservice("login")
    skynet.call(login, "lua", "open", {
        port = config.server.port,
        maxclient = 10000,
        nodelay = true,
    })



	logger.common.info("start login")
    skynet.exit()
end)
