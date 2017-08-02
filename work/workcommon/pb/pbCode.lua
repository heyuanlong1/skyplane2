
local pbCode = {}

-- 消息ID定义
pbCode.msg = {
	regReq							= 101,
	regResp							= 102,
	loginReq						= 111,
	loginResp						= 112,

	loginLobbyReq					= 113,
	loginLobbyResp					= 114,
	getRoomReq						= 115,
	getRoomResp						= 116,

	matchReq						= 121,
	matchResp						= 122,
	startGameReq					= 123,
	startGameResp					= 124,

	fightMsg						= 135,
	wailiTestLpushResponse			= 136,
	wailiTestSortRequest			= 137,
	wailiTestSortResponse			= 138,
}



-- req - > rep
local repToResp = {
	[pbCode.msg.regReq] 					= pbCode.msg.regResp,
	[pbCode.msg.loginReq] 					= pbCode.msg.loginResp,

	[pbCode.msg.loginLobbyReq] 				= pbCode.msg.loginLobbyResp,
	[pbCode.msg.getRoomReq] 				= pbCode.msg.getRoomResp,

	[pbCode.msg.matchReq] 					= pbCode.msg.matchResp,
	[pbCode.msg.startGameReq] 				= pbCode.msg.startGameResp,

	[pbCode.msg.wailiTestSortRequest] 		= pbCode.msg.wailiTestSortResponse,
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
	[pbCode.msg.getRoomReq] = "msg.getRoomReq",
	[pbCode.msg.getRoomResp] = "msg.getRoomResp",

	[pbCode.msg.matchReq] = "msg.matchReq",
	[pbCode.msg.matchResp] = "msg.matchResp",
	[pbCode.msg.startGameReq] = "msg.startGameReq",
	[pbCode.msg.startGameResp] = "msg.startGameResp",

	[pbCode.msg.fightMsg] = "msg.fightMsg",
	[pbCode.msg.matchResp] = "msg.matchResp",
	[pbCode.msg.wailiTestSortRequest] = "msg.wailiTestSortRequest",
	[pbCode.msg.wailiTestSortResponse] = "msg.wailiTestSortResponse",
}
function pbCode.getPBStrByMsgID(msgID)
	return msgIDToPBStr[msgID]
end

return pbCode
