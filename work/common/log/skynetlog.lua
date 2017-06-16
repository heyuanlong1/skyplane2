local skynet = require "skynet"


local level = 
{
    debug 		= 1,
    info 		= 2,
    warning 	= 3,
    error 		= 4,
}
local levelTags = 
{
    [level.debug] 		= "d",
    [level.info] 		= "i",
    [level.warning] 	= "w",
    [level.error] 		= "e",
}

local function defaultFormat(logLevel, moduleName, msg, ...)
    msg = string.format(msg, ...)
    return string.format([[[%s][%s][%s]:%s]], levelTags[logLevel], moduleName, os.date(os.date("%Y-%m-%d %H:%M:%S")), msg)
end

local function defaultOut(msg)
    skynet.error(msg)
end


local m = {}
m.level = level

function m.create(moduleName, logLevel, formatter, outer)
    formatter 	= formatter or defaultFormat
    outer 		= outer or defaultOut
    
    local logger = {}
    

    local function log(logLevel2, msg, ...)
        if logLevel2 >= logLevel then
            outer( formatter(logLevel2, moduleName, msg, ...)  )
        end
    end
    
    function logger.debug(msg, ...)
        log(level.debug, msg, ...)
    end
    function logger.info(msg, ...)
        log(level.info, msg, ...)
    end
    function logger.warning(msg, ...)
        log(level.warning, msg, ...)
    end
    function logger.error(msg, ...)
        log(level.error, msg, ...)
    end
    
    return logger
end

return m



