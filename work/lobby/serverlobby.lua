local skynet = require "skynet"
require "skynet.manager"
local cluster = require "cluster"
local commonlog 	= require "common.log.commonlog"
local config = require "config.lobbyConfig"

local interval = 5
local nodeName = "clusterServer"
local nodeService = "managerCluster"
local mode = ...

if mode == "call" then

	local CMD       = {}

	function CMD.start(service)
		while true do
			skynet.sleep(interval * 100)
			skynet.call(service,"lua","pulltrans") 			--定义让service去拉去trans
			skynet.call(service,"lua","pushlobby")
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

	local index		= 0			--轮训获取trans
	local transNums = 0			--trans数量
	local transList = {}		--trans存储

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

	function CMD.pushlobby()
		local addr = connectToServer(nodeName)
	    if addr == nil then
	    	commonlog.common.info("can not connect "..nodeName)
	    	return 
	    end

        local status ,msg= pcall(function()
            cluster.call(nodeName, addr, "pushlobby",config.lobbyServer.ip,config.lobbyServer.port)
        end)
        if not status then
            commonlog.common.info("pushlobby fail "..msg)
        end
	end
	function CMD.pulltrans()
	    local addr = connectToServer(nodeName)
	    if addr == nil then
	    	commonlog.common.info("can not connect "..nodeName)
	    	return 
	    end

        local status ,msg= pcall(function()
            return cluster.call(nodeName, addr, "pulltrans")
        end)
        if not status then
            commonlog.common.info("pulltrans fail "..msg)
            return
        end
        if msg.isChange == true then
        	transList = msg.items
        	transNums = #transList
        end
	end

	function CMD.gettrans()
		if transNums == 0 then
			return nil
		end
		index = index  + 1
	    if index > transNums then
	    	index = 1
	    end
	    return transNums[index]
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
