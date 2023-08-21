local ffi = require("ffi")
local core = require("RHooks.core")
local raknet = require("RHooks.const")
local utils = require("RHooks.classes.utils")


local RHooks = {}
function RHooks:new()
    local public
    local private


    private = {}

    function private:createHandler(handlerType, callback)
        local handler = core.handlers[handlerType]
        table.insert(handler, {callback = callback, processing = true})

        local proxy = {_index = #handler}
        local methods = {}
        function methods:setProcessing(toggle)
            handler[self._index].processing = toggle
        end
        function methods:destroy()
            table.remove(handler, self._index)
            setmetatable(self, nil)
        end
        function methods:getIndex()
            return self._index
        end

        local mt = {__index = methods}
        return setmetatable(proxy, mt)
    end


    public = {}

    public.name = "RHooks"
    public.author = "Ega"
    public.version = "0.6"

    ---Checks whether the library is initialized
    ---@return boolean initialized is there a pointer to the RakPeer
    function public:isInitialized()
        return (core.pvRakPeer ~= nil)
    end

    ---Retrieves the current version of SAMP
    ---@return string version current version
    function public:getSampVersion()
        return utils:getSampVersion()
    end

    ---Installs a handler on outgoing packets
    ---@param callback function function that will trigger when called
    ---@return table handler handler object 
    function public:onSendPacket(callback)
        return private:createHandler("CRakPeerSend", callback)
    end

    -----Installs a handler on ingoing packets
    -----@param callback function function that will trigger when called
    -----@return table handler handler object 
    -- function public:onReceivePacket(callback)
    --     return private:createHandler("CRakPeerReceive", callback)
    -- end

    ---Installs a handler on outgoing RPC
    ---@param callback function function that will trigger when called
    ---@return table handler handler object 
    function public:onSendRpc(callback)
        return private:createHandler("CRakPeerRPC", callback)
    end

    ---Installs a handler on ingoing RPC
    ---@param callback function function that will trigger when called
    ---@return table handler handler object 
    function public:onReceiveRpc(callback)
        return private:createHandler("CRakPeerHandleRPCPacket", callback)
    end

    ---Calls the RakPeer method to send the packet
    ---@param bs number BitStream pointer
    ---@param priority number packet priority
    ---@param reliability number packet reliability
    ---@param orderingChannel number packet orderingChannel
    ---@param binaryAddress number binary server address
    ---@param port number server port
    ---@param broadcast boolean packet broadcast
    ---@return boolean result has the packet been sent
    function public:rakPeerSend(bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast)
        return core.originalCRakPeerSend(core.pvRakPeer, bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast)
    end

    ---Calls the RakPeer method to send the RPC
    ---@param id number RPC ID
    ---@param bs number BitStream pointer
    ---@param priority number packet priority
    ---@param reliability number packet reliability
    ---@param orderingChannel number packet orderingChannel
    ---@param binaryAddress number binary server address
    ---@param port number server port
    ---@param broadcast boolean packet broadcast
    ---@param shiftTimestamp boolean 
    ---@param networkID number NetwordID pointer
    ---@param replyFromTarget number
    ---@param responseFromTarget number
    ---@return boolean result has the RPC been sent
    function public:rakPeerRPC(id, bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast, shiftTimestamp, networkID, replyFromTarget, responseFromTarget)
        local nId = ffi.new("char[1]", id)
        return core.originalCRakPeerRPC(core.pvRakPeer, nId, bs, priority, reliability, orderingChannel, binaryAddress, port, broadcast, shiftTimestamp, networkID, replyFromTarget, responseFromTarget)
    end

    ---Calls the RakClient method to send the packet
    ---@param bs number BitStream pointer
    ---@param priority number packet priority
    ---@param reliability number packet reliability
    ---@param orderingChannel number packet orderingChannel
    ---@return boolean result has the packet been sent
    function public:rakClientSend(bs, priority, reliability, orderingChannel)
        local RakClientPtr = self:getRakClientPtr()
        local pvRakClient = ffi.cast("void*", RakClientPtr)
        return self:callVirtualMethod(RakClientPtr, "bool(__thiscall*)(void* this, uintptr_t bitStream, char priority, char reliability, char orderingChannel)", 6, pvRakClient, bs, priority, reliability, orderingChannel)
    end

    ---Calls the RakClient method to send the RPC
    ---@param id number RPC ID
    ---@param bs number BitStream pointer
    ---@param priority number packet priority
    ---@param reliability number packet reliability
    ---@param orderingChannel number packet orderingChannel
    ---@param broadcast boolean
    ---@return boolean result has the packet been sent
    function public:rakClientRPC(id, bs, priority, reliability, orderingChannel, broadcast)
        local RakClientPtr = self:getRakClientPtr()
        local pvRakClient = ffi.cast("void*", RakClientPtr)
        local pId = ffi.new("int[1]", id)
        return self:callVirtualMethod(RakClientPtr, "bool(__thiscall*)(void* this, int* uniqueID, uintptr_t parameters, char priority, char reliability, char orderingChannel, bool shiftTimestamp)", 25, pvRakClient, pId, bs, priority, reliability, orderingChannel, broadcast)
    end

    ---Sends a packet to the server
    ---@param bs number BitStream pointer
    ---@return boolean result has the packet been sent
    function public:sendPacket(bs)
        return self:rakClientSend(bs, raknet.HIGH_PRIORITY, raknet.RELIABLE_ORDERED, 0)
    end

    ---Sends a RPC to the server
    ---@param id number RPC ID
    ---@param bs number BitStream pointer
    ---@return boolean result has the RPC been sent
    function public:sendRpc(id, bs)
        return self:rakClientRPC(id, bs, raknet.HIGH_PRIORITY, raknet.RELIABLE_ORDERED, 0, false)
    end

    ---Deletes the handler by index
    ---@param handlerType string type of handler
    ---@param iHandler number handler index
    function public:destroyHandlerByIndex(handlerType, iHandler)
        local handler = core.handlers[handlerType]
        if handler[iHandler] then
            if handler then table.remove(handler, iHandler)
            else utils:warningMessage("The handler name is incorrect.") end
        else
            utils:warningMessage(("Handler with index: %s - does not exist."):format(iHandler))
        end
    end

    ---Gets a pointer to RakPeer
    ---@return number pRakPeer RakPeer pointer
    function public:getRakPeerPtr()
        return utils:getPointer(core.pvRakPeer)
    end

    ---Gets a pointer to RakClient
    ---@return number pRakClient RakClient pointer
    function public:getRakClientPtr()
        return (self:getRakPeerPtr() + 0xDDE)
    end

    ---Gets the NetworkID
    ---@return number networkId NetwordID
    function public:getNetworkId()
        return 0xFFFFFFFF
    end

    ---Gets a pointer to PlayerID
    ---@return number pPlayerID PlayerID pointer
    function public:getPlayerIdPtr()
        local pPlayerId = ffi.cast("uintptr_t*", (self:getRakClientPtr() - 0xAAA))
        return pPlayerId[0]
    end

    ---Retrieves binaryAddress from PlayerID
    ---@return number binaryAddress binaryAddress from PlayerID
    function public:getPlayerIdBinaryAddress()
        local pPlayerId = self:getPlayerIdPtr()
        local pBinaryAddress = ffi.cast("uint32_t*", (pPlayerId + 0x1))
        return pBinaryAddress[0]
    end

    ---Retrieves port from PlayerID
    ---@return number port port from PlayerID
    function public:getPlayerIdPort()
        local pPlayerId = self:getPlayerIdPtr()
        local pPort = ffi.cast("uint16_t*", (pPlayerId + 0x5))
        return pPort[0]
    end

    ---Calls a virtual method from VMT
    ---@param vt number VMT pointer
    ---@param prototype string prototype of the method
    ---@param method number method index
    ---@param ... unknown method parameters
    ---@return unknown result method result
    function public:callVirtualMethod(vt, prototype, method, ...)
        return utils:callVirtualMethod(vt, prototype, method, ...)
    end


    setmetatable(public, self)
    self.__index = self
    return public
end


return RHooks:new()