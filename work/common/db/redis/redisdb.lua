local skynet = require "skynet"
require "skynet.manager"
local redis = require "redis"


local CMD = {}
local dbs = {}
local index = 0

function CMD.start(serviceName, conf, auth, num)
    skynet.register(serviceName)
    for i=1, num do
        local db = redis.connect(
        {
            host = conf.host,
            port = conf.port,
            db   = 0,
            auth = auth,
        })
        table.insert(dbs, db)
    end
end

function CMD.query(command, ...)
    index = index + 1
    if index > #dbs then
        index = 1
    end

    command = string.upper(command)
    return dbs[index][command](dbs[index], ...)
    
end

skynet.start(function()
    skynet.dispatch("lua", function(_, _, command, ...)
        if command == "start" then
            skynet.ret(skynet.pack(CMD.start(...)))
        else
            skynet.ret(skynet.pack(CMD.query(command, ...)))
        end    
    end)
end)