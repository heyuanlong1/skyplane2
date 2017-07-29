
local skynet = require "skynet"


local m = {}
local addr = ".redis_account"

local function nextUserid()
    return "nextAccountId"
end
local function useridKey(userid)
    return "userid:"..userid
end



function m.getNextUserid()
    return skynet.call(addr, "lua", "INCR", nextAccountIdKey())
end


function m.setUserLogin(userid,password)
    skynet.call(addr, "lua", "set", useridKey(userid), password)
    skynet.call(addr, "lua", "EXPIRE", useridKey(userid), 5 * 60)
end

function m.getUserPassword(userid)
    return skynet.call(addr, "lua", "get", useridKey(userid))
end


return m