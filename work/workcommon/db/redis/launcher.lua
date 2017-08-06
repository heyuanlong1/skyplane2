local skynet = require "skynet"
local logger        = require "common.log.commonlog"

local m = {}
function m.launchAccount(host,port ,auth)
    skynet.call(skynet.newservice("redisdb"), "lua", "start", ".redis_account", {host=host ,port=port }, auth, 4)
end


return m