local originalAddEventHandler = addEventHandler 


local SampFuncs = {}
function SampFuncs:new(RHooks)        
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
            local rakEvents = {"onSendPacket", "onReceivePacket", "onSendRpc", "onReceiveRpc"}            
            for _, rakEvent in ipairs(rakEvents) do                
                if (rakEvent == eventName) then                    
                    return RHooks[eventName](RHooks, callback)                    
                end
            end            
            return originalAddEventHandler(eventName, callback)
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