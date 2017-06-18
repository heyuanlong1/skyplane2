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
local stringbuffer = protobuf.encode(  pbCode.getPBStrByMsgID(pbCode.msg.loginReq),
    {
        deviceid = "longsddddddddd",
        userid=1,
    })
socket.send(fd, string.pack(">s2", string.pack("<I4", pbCode.msg.loginReq)..stringbuffer) )
local str   = socket.recv(fd)
if str == nil or str == "" then
    socket.close(fd)
    os.exit(0)
end
socket.close(fd)
local packet = string.unpack(">s2", str)
local msgId = string.unpack("<I4", packet)
local msg = string.sub(packet, 5)
local req, errormsg = protobuf.decode(pbCode.getPBStrByMsgID(msgId), msg, #msg)
local lobbyip = req.ip
local lobbyport = req.port
print("lobbyip:"..lobbyip)
print("lobbyport:"..lobbyport)


local fd = assert(socket.connect(lobbyip, lobbyport))
local stringbuffer = protobuf.encode(  pbCode.getPBStrByMsgID(pbCode.msg.matchReq),
    {
        
    })
socket.send(fd, string.pack(">s2", string.pack("<I4", pbCode.msg.matchReq)..stringbuffer) )

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
local transip = req.ip
local transport = req.port
print("transip:"..transip)
print("transport:"..transport)


local fd = assert(socket.connect(transip, transport))

while true do


    local stringbuffer = protobuf.encode(  pbCode.getPBStrByMsgID(pbCode.msg.fightMsg),
    {
        userid = 1111,
        roomid = 2,
        x = 333333,
        y = 444444,
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


