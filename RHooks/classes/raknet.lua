local ffi = require("ffi")
local utils = require("RHooks.classes.utils")
local offsets = require("RHooks.classes.offsets")


local sampHandle = utils:getSampHandle()


ffi.cdef[[
    typedef unsigned short PlayerIndex;
    
    typedef struct {       
        unsigned int binaryAddress;       
        unsigned short port;
    } PlayerID;

    typedef struct {
        PlayerIndex playerIndex;
        uintptr_t *playerId;
        unsigned int length;
        unsigned int bitSize;
        unsigned char *data;
        bool deleteData;
    } Packet;
]]


local RakNet = {}
function RakNet:new()
    local public
    local private


    private = {}
    
    private.packetsList = {
        INTERNAL_PING = 6,
        PING = 7,
        PING_OPEN_CONNECTIONS = 8,
        CONNECTED_PONG = 9,
        REQUEST_STATIC_DATA = 10,
        CONNECTION_REQUEST = 11,
        AUTH_KEY = 12,
        BROADCAST_PINGS = 14,
        SECURED_CONNECTION_RESPONSE = 15,
        SECURED_CONNECTION_CONFIRMATION = 16,
        RPC_MAPPING = 17,
        SET_RANDOM_NUMBER_SEED = 19,
        RPC = 20,
        RPC_REPLY = 21,
        DETECT_LOST_CONNECTIONS = 23,
        OPEN_CONNECTION_REQUEST = 24,
        OPEN_CONNECTION_REPLY = 25,
        CONNECTION_COOKIE = 26,
        RSA_PUBLIC_KEY_MISMATCH = 28,
        CONNECTION_ATTEMPT_FAILED = 29,
        NEW_INCOMING_CONNECTION = 30,
        NO_FREE_INCOMING_CONNECTIONS = 31,
        DISCONNECTION_NOTIFICATION = 32,
        CONNECTION_LOST = 33,
        CONNECTION_REQUEST_ACCEPTED = 34,
        INITIALIZE_ENCRYPTION = 35,
        CONNECTION_BANNED = 36,
        INVALID_PASSWORD = 37,
        MODIFIED_PACKET = 38,
        PONG = 39,
        TIMESTAMP = 40,
        RECEIVED_STATIC_DATA = 41,
        REMOTE_DISCONNECTION_NOTIFICATION = 42,
        REMOTE_CONNECTION_LOST = 43,
        REMOTE_NEW_INCOMING_CONNECTION = 44,
        REMOTE_EXISTING_CONNECTION = 45,
        REMOTE_STATIC_DATA = 46,
        ADVERTISE_SYSTEM = 56,
    }

    private.prioritiesList = {
        SYSTEM = 0,
        HIGH = 1,
        MEDIUM = 2,
        LOW = 3,
    }

    private.reliabilityList = {
        UNRELIABLE = 6,
        UNRELIABLE_SEQUENCED = 7,
        RELIABLE = 8,
        RELIABLE_ORDERED = 9,
        RELIABLE_SEQUENCED = 10
    }


    public = {}

    function public:getPacket(packetName)
        return private.packetsList[packetName]
    end

    function public:getPriority(priority)
        return private.prioritiesList[priority]
    end
    function public:getReliability(reliability)
        return private.reliabilityList[reliability]
    end

    function public:AllocPacket(dataSize, data)
        local input = ffi.cast("uint8_t*", data)
        local AllocPacket = ffi.cast("Packet*(__cdecl*)(unsigned dataSize, uint8_t *data)", (sampHandle + offsets:getAddress("AllocPacket")))
        return AllocPacket(dataSize, input)
    end

    function public:DeallocatePacket(pvRakPeer, packet)
        local CRakPeerDeallocatePacket = ffi.cast("int(__thiscall*)(void *this, Packet *packet)", (sampHandle + offsets:getAddress("CRakPeerDeallocatePacket")))
        return CRakPeerDeallocatePacket(pvRakPeer, packet)
    end    

    function public:AddPacketToProducer(pvRakPeer, packet)
        local CRakPeerAddPacketToProducer = ffi.cast("int(__thiscall*)(void *this, Packet *data)", (sampHandle + offsets:getAddress("CRakPeerAddPacketToProducer")))
        return CRakPeerAddPacketToProducer(pvRakPeer, packet)
    end

    function public:ReceiveIgnoreRPC(pvRakPeer)
        local CRakPeerReceiveIgnoreRPC = ffi.cast("Packet*(__thiscall*)(void *this)", (sampHandle + offsets:getAddress("CRakPeerReceiveIgnoreRPC")))
        local packet = CRakPeerReceiveIgnoreRPC(pvRakPeer)        
        return packet
    end


    setmetatable(public, self)
    self.__index = self
    return public
end



return RakNet:new()