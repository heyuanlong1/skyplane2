local skynet = require "skynet"
local config = require "config.lobbyConfig"
local redisdb = require "common.db.redis.redisdb"
local mysqldb = require "common.db.mysql.mysqldb"
local logger = require "common.log.commonlog"


skynet.start(function()
    
    local serverlobby = skynet.newservice("serverlobby")
    skynet.call(serverlobby, "lua", "start")



	commonlog.com.info("start lobby")
    skynet.exit()
end)
