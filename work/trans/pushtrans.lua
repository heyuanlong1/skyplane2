local skynet = require "skynet"
require "skynet.manager"
local cluster = require "cluster"
local commonlog 	= require "common.log.commonlog"
local config = require "config.transConfig"

local interval = 5
local nodeName = "clusterServer"
local nodeService = "managerCluster"
local mode = ...

if mode == "call" then

	local CMD       = {}

	function CMD.start(service)
		while true do
			skynet.sleep(interval * 100)
			skynet.call(service,"lua","pushtrans")
		end
	end

	skynet.start(function()
	    skynet.dispatch("lua", function( _, _, command, ... )
	        local f = CMD[command]
	        if f then
	            skynet.ret(skynet.pack(f(...)))
	        end
	    end)
	end)

else

	local CMD 		= {}
	local function connectToServer(nodeName)
	        local status, addr = xpcall(
	        function()
	            return cluster.query(nodeName, nodeService)
	        end, 
	        function(errormsg)  
	        end)
	        
	        if status then
	            return addr
	        else
	        	return nil
	        end

	end
	function CMD.pushtrans()
		local addr = connectToServer(nodeName)
	    if addr == nil then
	    	commonlog.common.info("can not connect "..nodeName)
	    	return 
	    end

        local status ,msg= pcall(function()
            cluster.call(nodeName, addr, "pushtrans",config.transServer.ip,config.transServer.port)
        end)
        if not status then
            commonlog.common.info("pushtrans fail "..msg)
        end
	end

	function CMD.start()
		local s = skynet.newservice(SERVICE_NAME, "call")
		skynet.send(s,"lua","start",skynet.self())
	end

	skynet.start(function()
		skynet.dispatch("lua", function( session, source, command, ... )
			local f = CMD[command]
	        if f then
	            skynet.ret(skynet.pack(f(...)))
	        end
		end)
	end)

end
