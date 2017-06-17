local skynet = require "skynet"
require "skynet.manager"
local cluster = require "cluster"
local commonlog 	= require "common.log.commonlog"


local interval = 5
local nodeName = "clusterServer"
local nodeService = "managerCluster"
local mode = ...

if mode == "call" then

	local CMD       = {}

	function CMD.start(service)
		local isFirst = true
		while true do
			skynet.sleep(interval * 100)
			skynet.call(service,"lua","pulllobby" ,isFirst) 			--定义让service去拉去lobby
			isFirst = false
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

	local index		= 0			--轮训获取lobby
	local lobbyNums = 0			--lobby数量
	local lobbyList = {}		--lobby存储 {{ip=**,port=**},{},...}

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

	function CMD.pulllobby(isFirst)
	    local addr = connectToServer(nodeName)
	    if addr == nil then
	    	commonlog.common.info("can not connect "..nodeName)
	    	return 
	    end

        local status ,msg= pcall(function()
            return cluster.call(nodeName, addr, "pulllobby",isFirst)
        end)
        if not status then
            commonlog.common.info("pulllobby fail "..msg)
            return
        end
        if msg.isChange == true then
        	lobbyList = msg.items
        	lobbyNums = #lobbyList
        end
	end

	function CMD.getlobby()
		if lobbyNums == 0 then
			return nil
		end
		index = index  + 1
	    if index > lobbyNums then
	    	index = 1
	    end
	    return lobbyList[index]
	end

	function CMD.start()
		skynet.register(".getlobby")
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
