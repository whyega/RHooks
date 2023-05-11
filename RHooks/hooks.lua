local BitStream = require("SFlua.bitstream")
local add = require("SFlua.addition")
local hooks = require("hooks")
local ffi = require("ffi")


local raknet = {}

local originalIncomingRpc, originalOutgoingPacket, originalIncomingPacket, originalOutgoingRpc
local originalCTimer__Update
local pSAMPInfo = 0

local samp = getModuleHandle("samp.dll")


function CTimer__Update()    
    pSAMPInfo = ffi.cast("uintptr_t*", (samp + 0x21A0F8))[0]
    if (pSAMPInfo == 0) then return originalCTimer__Update() end    
    raknet.pRakClient = ffi.cast("intptr_t*", (pSAMPInfo + 0x3C9))[0]    
    raknet.pRakPeer = ffi.cast("intptr_t*", (raknet.pRakClient - 0xDDE))[0]    
    originalCTimer__Update.stop()     
    return originalCTimer__Update.call()            
end


originalCTimer__Update = hooks.jmp.new(       
    "void(__cdecl*)()",        
    CTimer__Update, 0x561B10
) 

function addHandler(callback) -- —ƒ≈À¿“‹ ¬Œ«¬–¿Ÿ≈Õ»≈ ” ¿«¿“≈Àﬂ Õ¿ ‘”Õ ÷»» » œ–» Õ”∆ƒ≈ ”ƒ¿Àﬂ“‹ ’›ÕƒÀ≈–€
    local rakClient = hooks.vmt.new(raknet.pRakClient)    
    raknet.originalOutgoingRpc = rakClient.hookMethod("bool(__thiscall*)(void*, int*, SFL_BitStream*, char, char, char, bool)", handleOutgoingRpc, 25)        
end

function handleOutgoingRpc(this, id, bitStream, priority, reliability, orderingChannel, shiftTimestamp)
    local rpcId = ffi.cast("int *", id)[0]
    local pBitStream = add.GET_POINTER(bitStream)
    print("hooks rpc:", rpcId) 
    -- if (rpcId == 50) then        
    --     local command = raknetBitStreamReadString(pBitStream, raknetBitStreamReadInt32(pBitStream))        
    --     if (command == "/srpc") then   
    --         local cmd = "/cmds"                   
    --         local bs = BitStream()
    --         pBitStream = add.GET_POINTER(bs)
    --         raknetBitStreamWriteInt32(pBitStream, #cmd)
    --         raknetBitStreamWriteString(pBitStream, cmd)                       
    --         sendRpc(50, bs) 
    --         return false            
    --     end        
    -- end        
    return originalOutgoingRpc(this, id, bitStream, priority, reliability, orderingChannel, shiftTimestamp)
end

return raknet