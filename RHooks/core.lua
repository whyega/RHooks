local ffi = require("ffi")
local hooks = require("RHooks.hooks")
local raknet = require("RHooks.classes.raknet")
local offsets = require("RHooks.classes.offsets")
local utils = require("RHooks.classes.utils")
local BitStream = require("RHooks.classes.bitstream")


local originalCTimerUpdate
local sampHandle = utils:getSampHandle()

local core = {
    handlers = {
        CRakPeerSend = {},
        CRakPeerRPC = {},
        CRakPeerReceive = {},
        CRakPeerHandleRPCPacket = {}
    }
}


local function iterationHandlers(handlerType, bs, ...)
    local status, result
    for _, handler in ipairs(core.handlers[handlerType]) do
        if handler.processing then
            status, result = pcall(handler.callback, ...)
            if (result == false) then break
            elseif result then utils:warningMessage(result) end
        end
        pcall(function() bs:resetReadPointer() end)
    end
    return (result ~= false)
end


function CRakPeerSend(this, bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast)
    if not core.pvRakPeer then core.pvRakPeer = this end
    local bitStream = BitStream:new(bs)
    return ((iterationHandlers("CRakPeerSend", bitStream, bitStream, priority, reliability, orderingChannel, binaryAddress, port, broadcast) and core.originalCRakPeerSend(this, bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast)) or false)
end

-- function CRakPeerReceive(this)
--     local packet = raknet:ReceiveIgnoreRPC(this)
--     if (packet == nil) then return packet end
--     local pPacketId = ffi.cast("uint8_t**", (utils:getPointer(packet) + 16))[0]
--     local binaryAddress = ffi.cast("uint32_t*", (utils:getPointer(packet) + 2))
--     local port = ffi.cast("uint16_t*", (utils:getPointer(packet) + 6))
--     local length = ffi.cast("uint32_t*", (utils:getPointer(packet) + 8))
--     local data = ffi.cast("unsigned char**", (utils:getPointer(packet) + 16))
--     local packetId = pPacketId[0]
--     while ((packet ~= nil) and (packetId == raknet.packetsList.RPC) --[[and (length[0] > 5) or (packetId == 40) or data[5] == 20]]) do
--         print("iteration", this, data[0], length[0], binaryAddress[0], port[0])
--         core.originalCRakPeerHandleRPCPacket.call(this, data[0], length[0], binaryAddress[0], port[0])
--         packet = raknet:ReceiveIgnoreRPC(this)
--         raknet:DeallocatePacket(this, packet)
--     end
--     return ((iterationHandlers("CRakPeerReceive", packetId, packet) and packet) or false)
-- end

function CRakPeerReceive(this)
    local packet = raknet:ReceiveIgnoreRPC(this)
    if (packet == nil) then return packet end
    print(packet)
    -- print("pcall", pcall(function()
    --     print(packet, (packet == nil))
    --     while (packet ~= nil) --[[and (packetId == raknet.packetsList.RPC)]] do
    --         packet = raknet:ReceiveIgnoreRPC(this)
    --         raknet:DeallocatePacket(this, packet)
    --         print("postdeall")
    --     end
    -- end))
    return ((iterationHandlers("CRakPeerReceive", packetId, packet) and packet) or false)
end

function CRakPeerRPC(this, id, bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast, shiftTimestamp, networkID, replyFromTarget, responseFromTarget)
    local rpcId = id[0]
    local bitStream = BitStream:new(bs)
    return ((iterationHandlers("CRakPeerRPC", bitStream, rpcId, bitStream, priority, reliability, orderingChannel, binaryAddress, port, broadcast, shiftTimestamp, networkID, replyFromTarget, responseFromTarget) and core.originalCRakPeerRPC(this, id, bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast, shiftTimestamp, networkID, replyFromTarget, responseFromTarget)) or false)
end

-- function CRakPeerHandleRPCPacket(this, data, length, binaryAddress, port)    
-- --     print(pcall(function ()


-- --     local bs = BitStream:new(data, length, 1)
-- --     bs:ignoreBits(8)
-- --     if (data[0] == raknet.packetsList.TIMESTAMP) then bs:ignoreBits(40) end
-- --     local callbackBs
-- --     local bitsData = ffi.new("uint32_t[1]")   
-- --     local input = ffi.new("uint8_t[1]")    
-- --     local offset = bs:getReadOffset()
-- --     local rpcId = bs:readUInt8()    
-- --     local methods = bs:getBitStreamMethods()    
-- --     if (methods:ReadCompressed(bitsData, 32, 1) == 0) then return false end
-- --     if (bitsData ~= nil) then
-- --         local usedAlloca = false        
-- --         if (bs:getNumberOfUnreadBytes() < 1048576) then
-- --             input = ffi.cast("uint8_t*", ffi.new("uint8_t[?]", bs:getNumberOfUnreadBytes()))
-- --             usedAlloca = true
-- --         else input = ffi.new("uint8_t[?]", bs:getNumberOfUnreadBytes()) end
-- --         if (methods:Read(input, bitsData[0]) ~= 0) then
-- --             callbackBs = BitStream:new(input, utils:convertBitsToBytes(bitsData[0]), 1)
-- --         end             
-- --     end
-- --     bs:setWriteOffset(offset)
-- --     bs:writeInt8(rpcId)
-- --     bitsData = callbackBs:getNumberOfBitsUsed()
-- --     -- methods:WriteCompressed(bitsData, 32, 1)
-- --     -- if bitsData then
-- --     --     print(bitsData)
-- --     -- end   
-- -- end)) 
--     return ((iterationHandlers("CRakPeerHandleRPCPacket", rpcId, bs, binaryAddress, port) and core.originalCRakPeerHandleRPCPacket(this, data, length, binaryAddress, port)) or false)
-- end

function CRakPeerHandleRPCPacket(this, data, length, binaryAddress, port)
    local bs = BitStream:new(data, length, 1)
    bs:ignoreBits(8)
    if (data[0] == raknet:getPacket("TIMESTAMP")) then bs:ignoreBits(40) end
    local callbackBitStream
    local input
    local bitsData = ffi.new("uint32_t[1]")   
    local offset = bs:getReadOffset()
    local rpcId = bs:readUInt8()
    local originalBitStream = bs:getBitStream()
    if (originalBitStream:ReadCompressed(bitsData, 32, 1) == 0) then return false end
    if (bitsData ~= nil) then
        if (bs:getNumberOfUnreadBytes() < 1048576) then
            input = ffi.cast("uint8_t*", ffi.new("uint8_t[?]", bs:getNumberOfUnreadBytes()))
        end
        if (originalBitStream:Read(input, bitsData[0]) == 0) then
            return false
        end
        callbackBitStream = BitStream:new(input, bitsData[0], 1)        
    end
    iterationHandlers("CRakPeerHandleRPCPacket", callbackBitStream, rpcId, callbackBitStream, binaryAddress, port)
    bs:setWriteOffset(offset)
    bs:writeUInt8(rpcId)
    bitsData = ffi.new("uint32_t[1]", callbackBitStream:getNumberOfBitsUsed())
    originalBitStream:WriteCompressed(bitsData, 32, 1)
    if bitsData then
        originalBitStream:Write(callbackBitStream:getDataPtr(), callbackBitStream:getNumberOfBitsUsed(), 1)
    end
    return core.originalCRakPeerHandleRPCPacket(this, data, length, binaryAddress, port)
end

function ProcessNetworkPacket(binaryAddress, port, data, length, pRakPeer)    
    return core.originalProcessNetworkPacket(binaryAddress, port, data, length, pRakPeer)
end


function CTimerUpdate()
    local pNetGame = ffi.cast("uintptr_t*", (sampHandle + offsets:getAddress("CNetGame")))
    if (not pNetGame[0]) then return originalCTimerUpdate() end
    core.originalCRakPeerSend = hooks:new(
        "bool(__thiscall*)(void *this, uintptr_t bitStream, int priority, int reliability, char orderingChannel, unsigned int binaryAddress, unsigned short port, bool broadcast)",
        CRakPeerSend, (sampHandle + offsets:getAddress("CRakPeerSend"))
    )
    -- core.originalCRakPeerReceive = hooks:new(
    --     "Packet*(__thiscall*)(void *this)",
    --     CRakPeerReceive, (sampHandle + offsets:getAddress("CRakPeerReceive"))
    -- )
    core.originalCRakPeerRPC = hooks:new(
        "bool(__thiscall*)(void *this, uint8_t *uniqueID, uintptr_t bitStream, int priority, int reliability, char orderingChannel, unsigned int binaryAddress, unsigned short port, bool broadcast, bool shiftTimestamp, uintptr_t networkID, uintptr_t replyFromTarget, int responseFromTarget)",
        CRakPeerRPC, (sampHandle + offsets:getAddress("CRakPeerRPC"))
    )
    -- core.originalCRakPeerHandleRPCPacket = hooks:new(
    --     "bool(__thiscall*)(void *this, uint8_t *data, int length, unsigned int binaryAddress, unsigned short port)",
    --     CRakPeerHandleRPCPacket, (sampHandle + offsets:getAddress("CRakPeerHandleRPCPacket"))
    -- )
    -- core.originalProcessNetworkPacket = hooks:new(
    --     "void(__stdcall*)(unsigned int binaryAddress, unsigned short port, uint8_t *data, const unsigned int length, uintptr_t *RakPeer)",
    --     ProcessNetworkPacket, (sampHandle + offsets:getAddress("ProcessNetworkPacket"))
    -- )
    originalCTimerUpdate.stop()
    return originalCTimerUpdate.call()
end

originalCTimerUpdate = hooks:new(
    "void(__cdecl*)()",
    CTimerUpdate, offsets:getAddress("CTimerUpdate", true)
)


return core