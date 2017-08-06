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
        deviceid = "longssdddddddddd",
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
local lobbyip = req.lobbyip
local lobbyport = req.lobbyport
print("lobbyip:"..lobbyip)
print("lobbyport:"..lobbyport)
socket.close(fd)
---------------------------------------------------------------
os.exit(0)

local fd = assert(socket.connect(transip, transport))

while true do


    local stringbuffer = protobuf.encode(  pbCode.getPBStrByMsgID(pbCode.msg.fightMsg),
    {
        userid = 1,
        roomid = 2,
        x = 3,
        y = 4,
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
    print("userid:"..req.userid)
    print("roomid:"..req.roomid)
    print("x:"..req.x)
    print("y:"..req.y)

end


