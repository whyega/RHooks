local Sampfuncs = {}
function Sampfuncs:new(RHooksInterface)
    local public
    local private


    private = {}

    private.addEventHandler = addEventHandler    

    function private:sampSendChat(text)        
        local bs = RHooksInterface:BitStream()
        bs:writeString8(text)
        RHooksInterface:sendRpc(101, bs:getPointer())
        bs:delete()
    end

    function private:sampSendCommand(command)        
        local bs = RHooksInterface:BitStream()
        bs:writeString32(command)
        RHooksInterface:sendRpc(50, bs:getPointer())
        bs:delete()
    end


    local API = {}

    function API.addEventHandler(eventName, callback)
        local raknetEventsList = {"onSendPacket", "onReceivePacket", "onSendRpc", "onReceiveRpc"}       
        for _, event in ipairs(raknetEventsList) do
            if (event == eventName) then return RHooksInterface[eventName](RHooksInterface, callback) end
        end                
        return private.addEventHandler(eventName, callback)
    end

    function API.raknetNewBitStream()
        local bs = RHooksInterface:BitStream()
        return bs:getPointer()
    end

    function API.raknetBitStreamWriteInt8(bs, value)
        local bs = RHooksInterface:BitStream(bs)
        bs:writeInt8(value)
    end

    function API.raknetBitStreamWriteInt16(bs, value)
        local bs = RHooksInterface:BitStream(bs)
        bs:writeInt16(value)
    end

    function API.raknetBitStreamWriteInt32(bs, value)
        local bs = RHooksInterface:BitStream(bs)
        bs:writeInt32(value)
    end

    function API.raknetBitStreamWriteFloat(bs, value)
        local bs = RHooksInterface:BitStream(bs)
        bs:writeFloat(value)
    end

    function API.raknetBitStreamWriteBool(bs, value)
        local bs = RHooksInterface:BitStream(bs)
        bs:writeBool(value)
    end

    function API.raknetBitStreamWriteString(bs, str)
        local bs = RHooksInterface:BitStream(bs)
        bs:writeString(str)
    end

    function API.raknetBitStreamWriteBuffer(bs, dest, size)
        local bs = RHooksInterface:BitStream(bs)
        bs:writeBuffer(dest, size)
    end

    function API.raknetBitStreamReadInt8(bs)
        local bs = RHooksInterface:BitStream(bs)
        return bs:readInt8()
    end

    function API.raknetBitStreamReadInt16(bs)
        local bs = RHooksInterface:BitStream(bs)
        return bs:readInt16()
    end

    function API.raknetBitStreamReadInt32(bs)
        local bs = RHooksInterface:BitStream(bs)
        return bs:readInt32()
    end

    function API.raknetBitStreamReadFloat(bs)
        local bs = RHooksInterface:BitStream(bs)
        return bs:readFloat()
    end

    function API.raknetBitStreamReadBool(bs)
        local bs = RHooksInterface:BitStream(bs)
        return bs:readBool()
    end

    function API.raknetBitStreamReadString(bs, size)
        local bs = RHooksInterface:BitStream(bs)
        return bs:readString(size)
    end

    function API.raknetBitStreamReadBuffer(bs, output, size)
        local bs = RHooksInterface:BitStream(bs)
        return bs:readBuffer(output, size)
    end

    function API.raknetBitStreamIgnoreBits(bs, numberOfBits)
        local bs = RHooksInterface:BitStream(bs)
        return bs:ignoreBits(numberOfBits)
    end

    function API.raknetBitStreamResetWritePointer(bs)
        local bs = RHooksInterface:BitStream(bs)
        return bs:resetWritePointer()
    end

    function API.raknetBitStreamResetReadPointer(bs)
        local bs = RHooksInterface:BitStream(bs)
        return bs:resetReadPointer()
    end

    function API.raknetBitStreamSetWriteOffset(bs, offset)
        local bs = RHooksInterface:BitStream(bs)
        return bs:setWriteOffset(offset)
    end

    function API.raknetBitStreamSetReadOffset(bs, offset)
        local bs = RHooksInterface:BitStream(bs)
        return bs:setReadOffset(offset)
    end

    function API.raknetBitStreamGetNumberOfBitsUsed(bs)
        local bs = RHooksInterface:BitStream(bs)
        return bs:getNumberOfBitsUsed()
    end

    function API.raknetBitStreamGetNumberOfBytesUsed(bs)
        local bs = RHooksInterface:BitStream(bs)
        return bs:getNumberOfBytesUsed()
    end

    function API.raknetBitStreamGetNumberOfUnreadBits(bs)
        local bs = RHooksInterface:BitStream(bs)
        return bs:getNumberOfUnreadBits()
    end

    function API.raknetBitStreamGetWriteOffset(bs)
        local bs = RHooksInterface:BitStream(bs)
        return bs:getWriteOffset()
    end

    function API.raknetBitStreamGetReadOffset(bs)
        local bs = RHooksInterface:BitStream(bs)
        return bs:getReadOffset()
    end

    function API.raknetBitStreamGetDataPtr(bs)
        local bs = RHooksInterface:BitStream(bs)
        return bs:getDataPtr()
    end

    function API.raknetDeleteBitStream(bs)
        local bs = RHooksInterface:BitStream(bs)
        bs:delete()
    end

    function API:raknetSendBitStream(bs)
        return RHooksInterface:sendPacket(bs)
    end

    function API:raknetEmulPacketReceiveBitStream(id, bs)
        return RHooksInterface:emulatePacket(id, bs)
    end

    function API:raknetSendRpc(id, bs)
        return RHooksInterface:sendRpc(id, bs)
    end

    function API:raknetEmulRpcReceiveBitStream(id, bs)
        return RHooksInterface:emulateRpc(id, bs)
    end

    function API.sampSendChat(str)       
        if (str:sub(1, 1) == "/") then private:sampSendCommand(str)
        else private:sampSendChat(str) end
    end

    function API.sampSendClickPlayer(id, source)
        local bs = RHooksInterface:BitStream()
        bs:writeInt16(id)
        bs:writeInt8(source)
        RHooksInterface:sendRpc(23, bs:getPointer())
        bs:delete()
    end

    function API.sampSendClickTextdraw(id)
        local bs = RHooksInterface:BitStream()
        bs:writeInt16(id)
        RHooksInterface:sendRpc(83, bs:getPointer())
        bs:delete()
    end

    function API.sampSendDeathByPlayer(playerId, reason)
        local bs = RHooksInterface:BitStream()
        bs:writeInt16(playerId)
        bs:writeInt8(reason)
        RHooksInterface:sendRpc(53, bs:getPointer())
        bs:delete()
    end

    function API.sampSendDialogResponse(id, button, listitem, input)
        local bs = RHooksInterface:BitStream()
        bs:writeInt16(id)
        bs:writeInt8(button)
        bs:writeInt16(listitem)
        bs:writeString8(input)
        RHooksInterface:sendRpc(62, bs:getPointer())
        bs:delete()
    end

    function API.sampSendEditAttachedObject(response, index, model, bone, offsetX, offsetY, offsetZ, rotX, rotY, rotZ, scaleX, scaleY, scaleZ)
        local bs = RHooksInterface:BitStream()
        bs:writeInt32(response)
        bs:writeInt32(index)
        bs:writeInt32(model)
        bs:writeInt32(bone)
        bs:writeVector({offsetX, offsetY, offsetZ})
        bs:writeVector({rotX, rotY, rotZ})
        bs:writeVector({scaleX, scaleY, scaleZ})
        RHooksInterface:sendRpc(116, bs:getPointer())
        bs:delete()
    end

    function API.sampSendEditObject(playerObject, objectId, response, posX, posY, posZ, rotX, rotY, rotZ)
        local bs = RHooksInterface:BitStream()
        bs:writeBool(playerObject)
        bs:writeInt16(objectId)
        bs:writeInt32(response)
        bs:writeVector({posX, posY, posZ})
        bs:writeVector({rotX, rotY, rotZ})
        RHooksInterface:sendRpc(117, bs:getPointer())
        bs:delete()
    end

    function API.sampSendEnterVehicle(id, passenger)
        local bs = RHooksInterface:BitStream()
        bs:writeInt16(id)
        bs:writeBool(passenger)
        RHooksInterface:sendRpc(26, bs:getPointer())
        bs:delete()
    end

    function API.sampSendExitVehicle(vehicleId)
        local bs = RHooksInterface:BitStream()
        bs:writeInt16(vehicleId)
        RHooksInterface:sendRpc(154, bs:getPointer())
        bs:delete()
    end

    function API.sampSendGiveDamage(id, damage, weapon, bodypart)
        local bs = RHooksInterface:BitStream()
        bs:writeBool(false)
        bs:writeInt16(id)
        bs:writeFloat(damage)
        bs:writeInt32(weapon)
        bs:writeInt32(bodypart)
        RHooksInterface:sendRpc(115, bs:getPointer())
        bs:delete()
    end

    function API.sampSendTakeDamage(id, damage, weapon, bodypart)
        local bs = RHooksInterface:BitStream()
        bs:writeBool(true)
        bs:writeInt16(id)
        bs:writeFloat(damage)
        bs:writeInt32(weapon)
        bs:writeInt32(bodypart)
        RHooksInterface:sendRpc(115, bs:getPointer())
        bs:delete()
    end

    function API.sampSendInteriorChange(id)
        local bs = RHooksInterface:BitStream()        
        bs:writeInt8(id)        
        RHooksInterface:sendRpc(118, bs:getPointer())
        bs:delete()
    end

    function API.sampSendMenuQuit()
        local bs = RHooksInterface:BitStream()                     
        RHooksInterface:sendRpc(140, bs:getPointer())
        bs:delete()
    end

    function API.sampSendMenuSelectRow(id)
        local bs = RHooksInterface:BitStream()  
        bs:writeInt8(id)                        
        RHooksInterface:sendRpc(132, bs:getPointer())
        bs:delete()
    end

    function API.sampRegisterChatCommand(incomingCommand, callback)
        RHooksInterface:onSendRpc(function(id, bs)
            if (id == 50) then
                local currentCommand = bs:readString32()
                local croppedCommand = currentCommand:match("/(%S+)")                  
                if (incomingCommand == croppedCommand) then                    
                    local arg = currentCommand:match("/%S+ (.+)")
                    callback(arg)                    
                end
            end
        end)
    end


    public = {}

    function public:setGlobalVariables()
        for name, func in pairs(API) do
            _G[name] = func
        end
    end

    function public:destroyGlobalVariables()
        for name, _ in pairs(API) do
            _G[name] = nil
        end
    end


    setmetatable(public, self)
    self.__index = self
    return public
end


return Sampfuncs