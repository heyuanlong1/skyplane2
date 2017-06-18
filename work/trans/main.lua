local skynet = require "skynet"
local config = require "config.transConfig"
local redisdb = require "common.db.redis.redisdb"
local mysqldb = require "common.db.mysql.mysqldb"
local logger = require "common.log.commonlog"


skynet.start(function()
    
    local pushtrans = skynet.newservice("pushtrans")
    skynet.call(pushtrans, "lua", "start")

    local trans = skynet.newservice("trans")
    skynet.call(trans, "lua", "open", {
        port = config.server.port,
        maxclient = 10000,
        nodelay = true,
    })

    local fightroom = skynet.newservice("fightroom")
    skynet.call(fightroom, "lua", "start")

	logger.common.info("start lobby")
    skynet.exit()
end)
