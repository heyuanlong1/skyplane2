local logger = require "common.log.skynetlog"
return
{
    common 	= logger.create("common", logger.level.debug, nil, nil),
    web 	= logger.create("web", logger.level.debug, nil, nil),
}
