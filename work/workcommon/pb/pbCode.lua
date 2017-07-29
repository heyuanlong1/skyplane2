
local pbCode = {}

-- 消息ID定义
pbCode.msg = {
	regReq					= 101,
	regResp					= 102,
	loginReq				= 111,
	loginResp				= 112,

	loginLobbyReq			= 113,
	loginLobbyResp			= 114,
	fightMsg				= 115,
	wailiTestLpushResponse	= 116,
	wailiTestSortRequest	= 117,
	wailiTestSortResponse	= 118,
}



-- req - > rep
local repToResp = {
	[pbCode.msg.regReq] 	= pbCode.msg.regResp,
	[pbCode.msg.loginReq] 	= pbCode.msg.loginResp,
	[pbCode.msg.loginLobbyReq] 	= pbCode.msg.loginLobbyResp,
	[pbCode.msg.wailiTestSortRequest] = pbCode.msg.wailiTestSortResponse,
}
function pbCode.getRepToRespID(msgID)
	return repToResp[msgID]
end



-- ID 转换为protocol buffer 解析标示
local msgIDToPBStr = {
	[pbCode.msg.regReq] = "msg.regReq",
	[pbCode.msg.regResp] = "msg.regResp",
	[pbCode.msg.loginReq] = "msg.loginReq",
	[pbCode.msg.loginResp] = "msg.loginResp",
	[pbCode.msg.loginLobbyReq] = "msg.loginLobbyReq",
	[pbCode.msg.loginLobbyResp] = "msg.loginLobbyResp",
	[pbCode.msg.fightMsg] = "msg.fightMsg",
	[pbCode.msg.wailiTestLpushResponse] = "msg.wailiTestLpushResponse",
	[pbCode.msg.wailiTestSortRequest] = "msg.wailiTestSortRequest",
	[pbCode.msg.wailiTestSortResponse] = "msg.wailiTestSortResponse",
}
function pbCode.getPBStrByMsgID(msgID)
	return msgIDToPBStr[msgID]
end

return pbCode
