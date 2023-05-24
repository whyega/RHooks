require("RHooks.offsets")
require("RHooks.cdef")
local hooks = require("hooks")
local ffi = require("ffi")
local Utils = require("RHooks.classes.utils")


local originalCTimer__Update
local rakClient

local cast = ffi.cast
local samp = getModuleHandle("samp.dll")

local raknet = {
    handlers = {
        outgoingPacket = {},
        incomingPacket = {},
        outgoingRpc = {}, 
        incomingRpc = {}   
    }
}


jit.off(_, false) 


local function iterationHandlers(handlerType, ...)    
    local status, result
    for _, handler in ipairs(raknet.handlers[handlerType]) do   
        if handler.processing then     
            status, result = pcall(handler.callback, ...)          
            if (result == false) then 
                break 
            elseif result then
                print(result)
            end    
        end                                            
    end
    return (result ~= false)   
end

local function handleOutgoingPacket(this, bitStream, priority, reliability, orderingChannel)             
    return (iterationHandlers("outgoingPacket", bitStream, priority, reliability, orderingChannel) and raknet.originalOutgoingPacket(this, bitStream, priority, reliability, orderingChannel) or false)         
end

local function handleIncomingPacket(this, void)       
    local packet = raknet.originalIncomingPacket(this)              
    while (packet ~= nil) do       
        if (packet.data == nil) or (packet.length == 0) then break end              
        utils:callVirtualMethod(raknet.pRakClient[0], "void(__thiscall*)(void*, Packet*)", 9, this, packet)       
        packet = raknet.originalIncomingPacket(this)        
    end          
    return packet
end

local function handleOutgoingRpc(this, id, bitStream, priority, reliability, orderingChannel, shiftTimestamp)
    local nId = cast("int*", id)[0]     
    return (iterationHandlers("outgoingRpc", nId, bitStream, priority, reliability, orderingChannel, shiftTimestamp) and raknet.originalOutgoingRpc(this, id, bitStream, priority, reliability, orderingChannel, shiftTimestamp) or false)         
end

local function handleIncomingRpc(pRakPeer, void, data, length, playerId)  
    raknet.pRakPeer = pRakPeer   
    return (iterationHandlers("incomingRpc", void, data, length, playerId) and raknet.originalIncomingRpc(pRakPeer, void, data, length, playerId) or false)                          
end


local function CTimer__Update()         
    local pSAMPInfo = cast("uintptr_t*", getOffsetFromBase("sampInfo", samp))[0]
    if (pSAMPInfo == 0) then return originalCTimer__Update() end        

    raknet.pRakClient = cast("intptr_t*", getOffsetFromBase("rakClient", pSAMPInfo))   
        
    rakClient = hooks.vmt.new(raknet.pRakClient[0])
    raknet.originalOutgoingPacket = rakClient.hookMethod(
        "bool(__thiscall*)(void*, uintptr_t, char, char, char)", 
        handleOutgoingPacket, 6
    )     
    -- raknet.originalIncomingPacket = rakClient.hookMethod(
    --     "Packet*(__thiscall*)(void*, void)",
    --     handleIncomingPacket, 8
    -- )         
    raknet.originalOutgoingRpc = rakClient.hookMethod(
        "bool(__thiscall*)(void*, int*, uintptr_t, char, char, char, bool)", 
        handleOutgoingRpc, 25
    )                  
    raknet.originalIncomingRpc = hooks.jmp.new(       
        "void(__fastcall*)(void*, void*, unsigned char*, int, int)",        
        handleIncomingRpc, getOffsetFromBase("handleRpcPacket", samp)
    ) 

    originalCTimer__Update.stop()         
    return originalCTimer__Update.call()                             
end


originalCTimer__Update = hooks.jmp.new(       
    "void(__cdecl*)()",        
    CTimer__Update, getOffsetFromBase("CTimerUpdate")
)


return raknet