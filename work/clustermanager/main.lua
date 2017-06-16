local skynet = require "skynet"
local config = require "config.clusterManagerConfig"
local redisdb = require "common.db.redis.redisdb"
local mysqldb = require "common.db.mysql.mysqldb"
local logger = require "common.log.commonlog"


skynet.start(function()
    
    local clusterManager = skynet.newservice("managerCluster")
    skynet.call(clusterManager, "lua", "start")


	commonlog.com.info("start clustermanager")
    skynet.exit()
end)
