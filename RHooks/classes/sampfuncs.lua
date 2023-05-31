local BitStream = require("RHooks.classes.bitstream")


local originalAddEventHandler = addEventHandler 


local SampFuncs = {}
function SampFuncs:new(RHooks) -- To do    
    local public
    local private
    private = {}                         
        function private.raknetSendBitStream(bs, processing)
            return RHooks:sendPacket(bs, processing)
        end

        -- function private.raknetEmulPacketReceiveBitStream(id, bs, processing)
        --     return
        -- end

        function private.raknetSendRpc(id, bs, processing)            
            return RHooks:sendRpc(id, bs, processing)
        end 

        -- function private.raknetEmulRpcReceiveBitStream(id, bs, processing)
        --     return
        -- end       
                        
        function private.addEventHandler(eventName, callback)  
            local rakEvents = {"onSendPacket", "onReceivePacket", "onSendRpc", "onReceiveRpc"}  -- to the const          
            for _, rakEvent in ipairs(rakEvents) do                
                if (rakEvent == eventName) then                    
                    return RHooks[eventName](RHooks, callback)                    
                end
            end            
            return originalAddEventHandler(eventName, callback)
        end

        function private.sampSendChat(text)                 
            local bs = BitStream:raknetNewBitStream()
            BitStream:raknetBitStreamWriteInt8(bs, #text)
            BitStream:raknetBitStreamWriteString(bs, text)
            BitStream:sendRpc(101, bs)
            BitStream:raknetDeleteBitStream(bs)
        end

        function private.sampSendClickPlayer(id, source)
            
        end

        function private.sampSendClickTextdraw(id)
            
        end

        function private.sampSendDeathByPlayer(playerId, reason)
            
        end

    public = {}
        function public:setGlobalVariables()
            for k, v in pairs(private) do
                _G[k] = v
            end            
        end

    setmetatable(public, self)
    self.__index = self
    return public
end


return SampFuncs