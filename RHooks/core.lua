local ffi = require("ffi")
local hooks = require("RHooks.hooks")
local offsets = require("RHooks.classes.offsets")
local utils = require("RHooks.classes.utils")


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


local function iterationHandlers(handlerType, ...)
    local status, result
    for _, handler in ipairs(core.handlers[handlerType]) do
        if handler.processing then
            status, result = pcall(handler.callback, ...)
            if (result == false) then
                break
            elseif result then
                utils:warningMessage(result)
            end
        end
    end
    return (result ~= false)
end


function CRakPeerSend(this, bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast)
    if not core.pvRakPeer then core.pvRakPeer = this end
    return ((iterationHandlers("CRakPeerSend", bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast) and core.originalCRakPeerSend(this, bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast)) or false)
end

function CRakPeerReceive(this)
    local CRakPeerReceiveIgnoreRPC = ffi.cast("void*(__thiscall*)(void* this)", (sampHandle + offsets:getAddress("CRakPeerReceiveIgnoreRPC")))
    local packet = CRakPeerReceiveIgnoreRPC(this)
    if (packet == nil) then return packet end
    local pPacketId = ffi.cast("uint8_t**", (utils:getPointer(packet) + 16))[0]
    local binaryAddress = ffi.cast("uint32_t*", (utils:getPointer(packet) + 2))
    local port = ffi.cast("uint16_t*", (utils:getPointer(packet) + 6))
    local length = ffi.cast("uint32_t*", (utils:getPointer(packet) + 8))
    local data = ffi.cast("unsigned char**", (utils:getPointer(packet) + 16))
    local packetId = pPacketId[0]
    while ((packet ~= nil) and (packetId == 20) --[[and (length[0] > 5) or (packetId == 40) or data[5] == 20]]) do
        -- print(pcall(function() 
        print("iteration", this, data[0], length[0], binaryAddress[0], port[0])
        core.originalCRakPeerHandleRPCPacket.call(this, data[0], length[0], binaryAddress[0], port[0])
        packet = CRakPeerReceiveIgnoreRPC(this)
        local CRakPeerDeallocatePacket = ffi.cast("int(__thiscall*)(void* this, void* packet)", (sampHandle + offsets:getAddress("CRakPeerDeallocatePacket")))
        CRakPeerDeallocatePacket(this, packet)
        -- end))
    end
    return ((iterationHandlers("CRakPeerReceive", packetId, packet) and packet) or false)
end

function CRakPeerRPC(this, id, bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast, shiftTimestamp, networkID, replyFromTarget, responseFromTarget)
    local rpcId = id[0]
    return ((iterationHandlers("CRakPeerRPC", rpcId, bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast, shiftTimestamp, networkID, replyFromTarget, responseFromTarget) and core.originalCRakPeerRPC(this, id, bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast, shiftTimestamp, networkID, replyFromTarget, responseFromTarget)) or false)
end

function CRakPeerHandleRPCPacket(this, data, length, binaryAddress, port)
    return ((iterationHandlers("CRakPeerHandleRPCPacket", data, length, binaryAddress, port) and core.originalCRakPeerHandleRPCPacket(this, data, length, binaryAddress, port)) or false)
end


function CTimerUpdate()
    local pNetGame = ffi.cast("uintptr_t*", (sampHandle + offsets:getAddress("CNetGame")))
    if (not pNetGame[0]) then return originalCTimerUpdate() end
    core.originalCRakPeerSend = hooks:new(
        "bool(__thiscall*)(void *this, uintptr_t bitStream, int priority, int reliability, char orderingChannel, unsigned int binaryAddress, unsigned short port, bool broadcast)",
        CRakPeerSend, (sampHandle + offsets:getAddress("CRakPeerSend"))
    )
    -- core.originalCRakPeerReceive = hooks:new(
    --     "struct Packet*(__thiscall*)(void* this)",
    --     CRakPeerReceive, (sampHandle + offsets:getAddress("CRakPeerReceive"))
    -- )  
    core.originalCRakPeerRPC = hooks:new(
        "bool(__thiscall*)(void* this, char* uniqueID, uintptr_t bitStream, int priority, int reliability, char orderingChannel, unsigned int binaryAddress, unsigned short port, bool broadcast, bool shiftTimestamp, uintptr_t networkID, uintptr_t replyFromTarget, int responseFromTarget)",
        CRakPeerRPC, (sampHandle + offsets:getAddress("CRakPeerRPC"))
    )
    core.originalCRakPeerHandleRPCPacket = hooks:new(
        "bool(__thiscall*)(void* this, unsigned char* data, int length, unsigned int binaryAddress, unsigned short port)",
        CRakPeerHandleRPCPacket, (sampHandle + offsets:getAddress("CRakPeerHandleRPCPacket"))
    )
    originalCTimerUpdate.stop()
    return originalCTimerUpdate.call()
end

originalCTimerUpdate = hooks:new(
    "void(__cdecl*)()",
    CTimerUpdate, offsets:getAddress("CTimerUpdate", true)
)


return core