local skynet            = require "skynet"
require "skynet.manager"
local socket            = require "socket"
local httpd             = require "http.httpd"
local sockethelper      = require "http.sockethelper"
local urllib            = require "http.url"
local commonlog         = require "common.log.commonlog"


local mode = ...

if mode == "agent" then

local function response(fd, ...)
	local ok, err = httpd.write_response(sockethelper.writefunc(fd), ...)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		commonlog.web.error("web response error, fd = %d, %s", fd, err)
	end
end

local CMD = {}

local service = {}

function CMD.registerService(name, addr)
    if service[name] then
        commonlog.web.error("service has been registered:"..name)
    end
    service[name] = addr
end

function CMD.query(fd)
    socket.start(fd)
    -- limit request body size to 8192 (you can pass nil to unlimit)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(fd), 8192)

    if code then
        if code ~= 200 then
            response(fd, code)
        else
        
            local path, query = urllib.parse(url)
            if query then
                query = urllib.parse_query(query)
            end
            
            local serviceName = string.sub(path, 2, -1)
            if service[serviceName] then
                local ret = skynet.call(service[serviceName], "lua", "run", query)
                response(fd, code, ret)
            else
                response(fd, code, [[{"status":1 ,"code":1000,"msg":"no service:]]..serviceName..[["}]])
            end
        
            
        end
    else
        if url == sockethelper.socket_error then
        else
            commonlog.web.error("web read_request error, %s", url)
        end
    end
    socket.close(fd)
end

skynet.start(function()
	skynet.dispatch("lua", function (_, _, command, ...)
        local f = CMD[command]
        f(...)
	end)
end)

else

local CMD = {}
local agent = {}

function CMD.start(host, port)
    skynet.register(".web")
    
    for i= 1, 20 do
        agent[i] = skynet.newservice(SERVICE_NAME, "agent")
    end
    local balance = 1
    
    local id = socket.listen(host, port)

    
    socket.start(id , function(fd, addr)
        
        skynet.send(agent[balance], "lua", "query", fd)
        balance = balance + 1
        if balance > #agent then
            balance = 1
        end
    end)
end

function CMD.registerService(name, addr)
    for i, v in ipairs(agent) do
        skynet.send(v, "lua", "registerService", name, addr)
    end
end
    
skynet.start(function()
    
    skynet.dispatch("lua", function(_, _, command, ...)
        local f = CMD[command]
        skynet.ret(skynet.pack(f(...)))
    end)
    
end)

end