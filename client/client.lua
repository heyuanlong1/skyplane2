package.cpath = "skynetlib/luaclib/?.so"
package.path = "skynetlib/lualib/?.lua;work/?.lua"

if _VERSION ~= "Lua 5.3" then
    error "Use lua 5.3"
end

local socket        = require "clientsocket"
local protobuf      = require "protobuf"
local pbCode        = require "workcommon/pb/pbCode"

--加载pb
local pbFile
pbFile = io.open("work/workcommon/pb/msg.pb", "rb")
protobuf.register(pbFile:read("*a"))
pbFile:close()



local fd = assert(socket.connect("127.0.0.1", 9021))
---------------------------------------------------------------

local stringbuffer = protobuf.encode(  pbCode.getPBStrByMsgID(pbCode.msg.regReq),
    {
        deviceid = "longsddddddddd",
    })
socket.send(fd, string.pack(">s2", string.pack("<I4", pbCode.msg.regReq)..stringbuffer) )
local str   = socket.recv(fd)
if str == nil or str == "" then
    socket.close(fd)
    os.exit(0)
end
local packet = string.unpack(">s2", str)
local msgId = string.unpack("<I4", packet)
local msg = string.sub(packet, 5)
local req, errormsg = protobuf.decode(pbCode.getPBStrByMsgID(msgId), msg, #msg)
local userid = req.userid
local password = req.password
print("userid:"..userid)
print("password:"..password)


-------------------------------

local stringbuffer = protobuf.encode(  pbCode.getPBStrByMsgID(pbCode.msg.loginReq),
    {
        userid=userid,
        password=password,
    })
socket.send(fd, string.pack(">s2", string.pack("<I4", pbCode.msg.loginReq)..stringbuffer) )
local str   = socket.recv(fd)
if str == nil or str == "" then
    socket.close(fd)
    os.exit(0)
end

local packet = string.unpack(">s2", str)
local msgId = string.unpack("<I4", packet)
local msg = string.sub(packet, 5)
local req, errormsg = protobuf.decode(pbCode.getPBStrByMsgID(msgId), msg, #msg)
local lobbyip = req.lobbyip
local lobbyport = req.lobbyport
print("lobbyip:"..lobbyip)
print("lobbyport:"..lobbyport)

socket.close(fd)
print("")
---------------------------------------------------------------

local fd = assert(socket.connect(lobbyip, lobbyport))
local stringbuffer = protobuf.encode(  pbCode.getPBStrByMsgID(pbCode.msg.loginLobbyReq),
    {
        userid=userid,
        password=password,
    })
socket.send(fd, string.pack(">s2", string.pack("<I4", pbCode.msg.loginLobbyReq)..stringbuffer) )
local str   = socket.recv(fd)
if str == nil or str == "" then
    socket.close(fd)
    os.exit(0)
end
local packet = string.unpack(">s2", str)
local msgId = string.unpack("<I4", packet)
local msg = string.sub(packet, 5)
local req, errormsg = protobuf.decode(pbCode.getPBStrByMsgID(msgId), msg, #msg)
local errorCode = req.errorCode
print("login lobby errorCode:"..errorCode)

----------------------------

local stringbuffer = protobuf.encode(  pbCode.getPBStrByMsgID(pbCode.msg.getRoomAddrReq),
    {
    })
socket.send(fd, string.pack(">s2", string.pack("<I4", pbCode.msg.getRoomAddrReq)..stringbuffer) )
local str   = socket.recv(fd)
if str == nil or str == "" then
    socket.close(fd)
    os.exit(0)
end
local packet = string.unpack(">s2", str)
local msgId = string.unpack("<I4", packet)
local msg = string.sub(packet, 5)
local req, errormsg = protobuf.decode(pbCode.getPBStrByMsgID(msgId), msg, #msg)
local roomip = req.roomip
local roomport = req.roomport
local errorCode = req.errorCode
print("errorCode:"..errorCode)
print("roomip:"..roomip)
print("roomport:"..roomport)
socket.close(fd)
print("")
---------------------------------------------------------------


local fd = assert(socket.connect(roomip, roomport))
local stringbuffer = protobuf.encode(  pbCode.getPBStrByMsgID(pbCode.msg.matchReq),
    {
        userid=userid,
        roomtype="pvp2",
    })
socket.send(fd, string.pack(">s2", string.pack("<I4", pbCode.msg.matchReq)..stringbuffer) )
local str   = socket.recv(fd)
if str == nil or str == "" then
    print("matchReq fail")
    socket.close(fd)
    os.exit(0)
end
local packet = string.unpack(">s2", str)
local msgId = string.unpack("<I4", packet)
local msg = string.sub(packet, 5)
local req, errormsg = protobuf.decode(pbCode.getPBStrByMsgID(msgId), msg, #msg)
local roomid = req.roomid
local errorCode = req.errorCode
local isstart = req.isstart
print("errorCode:"..errorCode)
print("roomid:"..roomid)
print("isstart:",isstart)


----------------------------

local stringbuffer = protobuf.encode(  pbCode.getPBStrByMsgID(pbCode.msg.startGameReq),
    {
    roomid = roomid
    })
socket.send(fd, string.pack(">s2", string.pack("<I4", pbCode.msg.startGameReq)..stringbuffer) )
local str   = socket.recv(fd)
if str == nil or str == "" then
    socket.close(fd)
    os.exit(0)
end
local packet = string.unpack(">s2", str)
local msgId = string.unpack("<I4", packet)
local msg = string.sub(packet, 5)
local req, errormsg = protobuf.decode(pbCode.getPBStrByMsgID(msgId), msg, #msg)
local errorCode = req.errorCode
local isstart = req.isstart
print("errorCode:"..errorCode)
print("isstart:",isstart)
---------------------------------------------------------------



while true do

    local stringbuffer = protobuf.encode(  pbCode.getPBStrByMsgID(pbCode.msg.fightMsg),
    {
        userid = userid,
        roomid = roomid,
        msg = "xxxxxxxxxxx"
    })
    socket.send(fd, string.pack(">s2", string.pack("<I4", pbCode.msg.fightMsg)..stringbuffer) )

    local str 
    while true do 
        str = socket.recv(fd)
        if str ~= nil then
            break
        end
    end

    local packet = string.unpack(">s2", str)
    local msgId = string.unpack("<I4", packet)
    local msg = string.sub(packet, 5)
    local req, errormsg = protobuf.decode(pbCode.getPBStrByMsgID(msgId), msg, #msg)
    if msgId == pbCode.msg.fightMsg then
        print("userid:",req.userid)
        print("roomid:",req.roomid)
        print("msg:",req.msg)
    elseif msgId == pbCode.msg.fightMsgResp then
        print("errorCode:",req.errorCode)
        break
    else
    end 

end


