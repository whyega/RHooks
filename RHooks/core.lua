require("RHooks.offsets")
local hooks = require("hooks")
local ffi = require("ffi")


local originalCTimer__Update
local rakClient
local pSAMPInfo = 0

local cast = ffi.cast
local samp = getModuleHandle("samp.dll")

local raknet = {}
raknet.handlers = {
    outgoingPacket = {},
    incomingPacket = {},
    outgoingRpc = {}, 
    incomingRpc = {}   
}


jit.off(_, false)

local function CTimer__Update()            
    pSAMPInfo = cast("uintptr_t*", getOffsetFromBase("sampInfo", samp))[0]
    if (pSAMPInfo == 0) then return originalCTimer__Update() end        

    raknet.pRakClient = cast("intptr_t*", getOffsetFromBase("rakClient", pSAMPInfo))   
    raknet.pRakPeer = cast("intptr_t*", (raknet.pRakClient[0] - 0xDDE))  
     
    rakClient = hooks.vmt.new(raknet.pRakClient[0])
    raknet.originalOutgoingPacket = rakClient.hookMethod(
        "bool(__thiscall*)(void*, uintptr_t, char, char, char)", 
        handleOutgoingPacket, 6
    ) 
    -- raknet.originalIncomingPacket = rakClient.hookMethod(
    --     "bool(__thiscall*)(void*, uintptr_t, char, char, char)",
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


function raknet.RPC(ptr, id, bs, priority, reliability, orderingChannel, shiftTimestamp)
    local pId = ffi.new("int[1]", id) 
    return raknet.originalOutgoingRpc(ptr, pId, bs, priority, reliability, orderingChannel, shiftTimestamp)    
end


function iterationHandlers(handlerType, ...)    
    for _, callback in ipairs(raknet.handlers[handlerType]) do        
        local status, result = pcall(callback, ...)                    
        if (result == false) then return false end  
    end
end

function handleOutgoingPacket(this, bitStream, priority, reliability, orderingChannel)             
    return (iterationHandlers("outgoingPacket", bitStream, priority, reliability, orderingChannel) == false) and false or raknet.originalOutgoingPacket(this, bitStream, priority, reliability, orderingChannel)
end

function handleIncomingPacket(this, bitStream, priority, reliability, orderingChannel)      
    for _, callback in ipairs(raknet.handlers.incomingPacket) do                     
        local status, result = pcall(callback, bitStream, priority, reliability, orderingChannel)                    
        if (result == false) then return false end  
    end   
    return raknet.originalIncomingPacket(this, bitStream, priority, reliability, orderingChannel)
end

function handleOutgoingRpc(this, id, bitStream, priority, reliability, orderingChannel, shiftTimestamp)
    local nId = ffi.cast("int*", id)[0]     
    return (iterationHandlers("outgoingRpc", nId, bitStream, priority, reliability, orderingChannel, shiftTimestamp) == false) and false or raknet.originalOutgoingRpc(this, id, bitStream, priority, reliability, orderingChannel, shiftTimestamp)    
end

function handleIncomingRpc(this, void, data, length, playerId) 
    for _, callback in ipairs(raknet.handlers.incomingRpc) do                        
        local status, result = pcall(callback, void, data, length, playerId)                    
        if (result == false) then return false end    
    end
    return raknet.originalIncomingRpc(this, void, data, length, playerId)    
end

return raknet