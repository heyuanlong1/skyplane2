local skynet = require "skynet"
local config = require "config.transConfig"
local redisdb = require "common.db.redis.redisdb"
local mysqldb = require "common.db.mysql.mysqldb"
local logger = require "common.log.commonlog"


skynet.start(function()
    
    local pushtrans = skynet.newservice("pushtrans")
    skynet.call(pushtrans, "lua", "start")



	logger.common.info("start lobby")
    skynet.exit()
end)
