local skynet = require "skynet"
local skynet = require "skynet.manager"
local cluster = require "cluster"
local commonlog 	= require "common.log.commonlog"
local utils 		= require "common.tools.utils"

local nodeName 			= "clusterServer"
local nodeService 		= "managerCluster"
local interval 			= 5
local expiretime 		= 10

local mode = ...

if mode == "call" then

	local CMD       = {}
	function CMD.start(service)
		while true do
			skynet.sleep(interval * 100)
			skynet.call(service,"lua","checklobby") 			--定义让service去拉去trans
			skynet.call(service,"lua","checktrans")
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
	local lobbyMap  = {isChange = false,items = {} }
	local transMap  = {isChange = false,items = {} }

	function CMD.start()
	    cluster.open(nodeName)
	    cluster.register(nodeService)

	    local s = skynet.newservice(SERVICE_NAME, "call")
		skynet.send(s,"lua","start",skynet.self())
	end



	function CMD.pushlobby(ip,port)
		commonlog.common.info("CMD.pushlobby()"..ip..":"..port)
		local key = ip.."___"..port
		if lobbyMap.items[key] == nil then
			lobbyMap.isChange = true
		end
	    lobbyMap.items[key] = skynet.time()
	end
	function CMD.pushtrans(ip,port)
		commonlog.common.info("CMD.pushtrans()"..ip..":"..port)
		local key = ip.."___"..port
		if transMap.items[key] == nil then
			transMap.isChange = true
		end
	    transMap.items[key] = skynet.time()
	end
	function CMD.pulllobby(isFirst)
		commonlog.common.info("CMD.pulllobby()")
		local ret
	    if lobbyMap.isChange == false and isFirst == false then
	    	ret = {isChange = false,items = {} }
	    else
	    	ret = {isChange = true,items = {} }
	    	local arr
	    	for k,v in pairs(lobbyMap.items) do
	    		arr = utils.Split(k,"___")
	    		table.insert(ret.items,{ip = arr[1],port = arr[2]})
	    	end
	    end
	    lobbyMap.isChange = false
	    return ret
	end
	function CMD.pulltrans(isFirst)
		commonlog.common.info("CMD.pulltrans()")
		local ret
	    if transMap.isChange == false and isFirst == false then
	    	ret =  {isChange = false,items = {} }
	    else
	    	ret = {isChange = true,items = {} }
	    	local arr
	    	for k,v in pairs(transMap.items) do
	    		arr = utils.Split(k,"___")
	    		table.insert(ret.items,{ip = arr[1],port = arr[2]})
	    	end
	    end
	    transMap.isChange = false
	    return ret
	end
	function CMD.checklobby()
		local t = skynet.time()
		local list = {}
	    for k,v in pairs(lobbyMap.items) do
	    	if (t - v) > expiretime then
	    		table.insert(list,k)
	    	end
	    end
	    if #list > 0 then	    	
	    	for i,v in ipairs(list) do
	    		lobbyMap.items[v] = nil
	    	end
	    	lobbyMap.isChange = true
	    end
	end
	function CMD.checktrans()
	    local t = skynet.time()
		local list = {}
	    for k,v in pairs(transMap.items) do
	    	if (t - v) > expiretime then
	    		table.insert(list,k)
	    	end
	    end
	    if #list > 0 then	    	
	    	for i,v in ipairs(list) do
	    		transMap.items[v] = nil
	    	end
	    	transMap.isChange = true
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
end