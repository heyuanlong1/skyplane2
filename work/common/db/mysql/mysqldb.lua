local skynet = require "skynet"
require "skynet.manager"
local mysql = require "mysql"

local CMD = {}
local dbs = {}
local index = 0

function CMD.start(serviceName, conf, auth, num)
    skynet.register(serviceName)
    for i=1, num do
        local db
        db = mysql.connect(
        {
            host = conf.host,
            port = conf.port,
            database = conf.database,
            user = auth.user,
            password = auth.password,
            max_packet_size = 1024 * 1024,
            on_connect = function()

                skynet.fork(function()
                    db:query("set character set utf8;")
                    db:query('set character_set_connection="utf8";')
                    while true do
                        skynet.sleep(3600 * 100)
                        db:query("select version();")
                    end
                end)
            end
        })
        table.insert(dbs, db)
    end
end

function CMD.query(sql, ignoreError)
    index = index + 1
    if index > #dbs then
        index = 1
    end
    local result = dbs[index]:query(sql)
    if not ignoreError and result.errno then
       skynet.error(string.format("sql执行错误: %s\n errno:%d", sql,result.errno) )
    end
    return result
end

skynet.start(function()
    skynet.dispatch("lua", function(_, _, command, ...)
        local f = assert(CMD[command])
        skynet.ret(skynet.pack(f(...)))
    end)
end)
