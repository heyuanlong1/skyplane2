
local pbCode = {}

-- 消息ID定义
pbCode.msg = {
	loginReq				= 111,
	loginResp				= 112,
	matchReq				= 113,
	matchResp			= 114,
	fightMsg	= 115,
	wailiTestLpushResponse	= 116,
	wailiTestSortRequest	= 117,
	wailiTestSortResponse	= 118,
}



-- req - > rep
local repToResp = {
	[pbCode.msg.loginReq] = pbCode.msg.loginResp,
	[pbCode.msg.matchReq] = pbCode.msg.matchResp,
	[pbCode.msg.wailiTestSortRequest] = pbCode.msg.wailiTestSortResponse,
}
function pbCode.getRepToRespID(msgID)
	return repToResp[msgID]
end



-- ID 转换为protocol buffer 解析标示
local msgIDToPBStr = {
	[pbCode.msg.loginReq] = "msg.loginReq",
	[pbCode.msg.loginResp] = "msg.loginResp",
	[pbCode.msg.matchReq] = "msg.matchReq",
	[pbCode.msg.matchResp] = "msg.matchResp",
	[pbCode.msg.fightMsg] = "msg.fightMsg",
	[pbCode.msg.wailiTestLpushResponse] = "msg.wailiTestLpushResponse",
	[pbCode.msg.wailiTestSortRequest] = "msg.wailiTestSortRequest",
	[pbCode.msg.wailiTestSortResponse] = "msg.wailiTestSortResponse",
}
function pbCode.getPBStrByMsgID(msgID)
	return msgIDToPBStr[msgID]
end

return pbCode
