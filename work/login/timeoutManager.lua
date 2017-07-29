local skynet = require "skynet"
require "skynet.manager"
local logger = require "common.log.commonlog"


function login_timeout_fd( ... )
	skynet.timeout(60 * 100, login_timeout_fd)
	skynet.send(".login","lua","timeoutClosefd")
end




local CMD 		= {}
function CMD.start()
	skynet.timeout(60, login_timeout_fd)
end

skynet.start(function()
	skynet.dispatch("lua", function( session, source, command, ... )
		local f = CMD[command]
        if f then
            skynet.ret(skynet.pack(f(...)))
        end
	end)
end)



