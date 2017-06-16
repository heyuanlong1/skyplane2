
local pbCode = {}

-- 消息ID定义
pbCode.clientToServerMsg = {
	wailiTestRegRequest		= 111,
	wailiTestRegResponse	= 112,
	wailiTestLoginRequest	= 113,
	wailiTestLoginResponse	= 114,
	wailiTestLpushRequest	= 115,
	wailiTestLpushResponse	= 116,
	wailiTestSortRequest	= 117,
	wailiTestSortResponse	= 118,
}



-- req - > rep
local repToResponse = {
	[pbCode.clientToServerMsg.wailiTestRegRequest] = pbCode.clientToServerMsg.wailiTestRegResponse,
	[pbCode.clientToServerMsg.wailiTestLoginRequest] = pbCode.clientToServerMsg.wailiTestLoginResponse,
	[pbCode.clientToServerMsg.wailiTestLpushRequest] = pbCode.clientToServerMsg.wailiTestLpushResponse,
	[pbCode.clientToServerMsg.wailiTestSortRequest] = pbCode.clientToServerMsg.wailiTestSortResponse,
}
function pbCode.getRepToResponseID(msgID)
	return repToResponse[msgID]
end



-- ID 转换为protocol buffer 解析标示
local msgIDToProtoBufStr = {
	[pbCode.clientToServerMsg.wailiTestRegRequest] = "clientToServerMsg.wailiTestRegRequest",
	[pbCode.clientToServerMsg.wailiTestRegResponse] = "clientToServerMsg.wailiTestRegResponse",
	[pbCode.clientToServerMsg.wailiTestLoginRequest] = "clientToServerMsg.wailiTestLoginRequest",
	[pbCode.clientToServerMsg.wailiTestLoginResponse] = "clientToServerMsg.wailiTestLoginResponse",
	[pbCode.clientToServerMsg.wailiTestLpushRequest] = "clientToServerMsg.wailiTestLpushRequest",
	[pbCode.clientToServerMsg.wailiTestLpushResponse] = "clientToServerMsg.wailiTestLpushResponse",
	[pbCode.clientToServerMsg.wailiTestSortRequest] = "clientToServerMsg.wailiTestSortRequest",
	[pbCode.clientToServerMsg.wailiTestSortResponse] = "clientToServerMsg.wailiTestSortResponse",
}
function pbCode.getProtoBuffStrByMsgID(msgID)
	return msgIDToProtoBufStr[msgID]
end

return pbCode
