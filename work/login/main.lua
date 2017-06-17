local skynet = require "skynet"
local config = require "config.loginConfig"
local redisdb = require "common.db.redis.redisdb"
local mysqldb = require "common.db.mysql.mysqldb"
local logger = require "common.log.commonlog"


skynet.start(function()
    
    local getlobby = skynet.newservice("getlobby")
    skynet.call(getlobby, "lua", "start")



	logger.common.info("start login")
    skynet.exit()
end)
