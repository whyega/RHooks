local ffi = require("ffi")
local rakConst = require("RHooks.const")
local raknet = require("RHooks.core")
local SF = require("RHooks.classes.sampfuncs")
local utils = require("RHooks.classes.utils")


local IRHooks = {}
function IRHooks:new()        
    local public 
    local private
    private = {}             
        function private:createHandler(typeHandler, callback)
            local handlers = raknet.handlers[typeHandler]                         
            table.insert(handlers, {callback = callback, processing = true})                
            return setmetatable({index = #handlers}, {
                __index = {
                    setProcessing = function(self, actived) 
                        handlers[self.index].processing = actived
                    end,                    
                    destroy = function(self)                                                                                                                    
                        table.remove(handlers, self.index) 
                        setmetatable(self, nil)
                    end,
                    getIndex = function(self)
                        return self.index
                    end
                }                               
            })         
        end   

    public = {}        
        function public:isInitialized()
            return (raknet.pRakClient and raknet.pRakPeer)
        end

        function public:getSampVersion()
            return utils:getSampVersion()
        end
        
        function public:addSupportForSampFuncs()            
            local sampfuncs = SF:new(self) 
            sampfuncs:setGlobalVariables()            
        end
       
        function public:sendPacket(bs, processing)           
            if not self:isInitialized() then return false end  
            local pRakClient = ffi.cast("void*", raknet.pRakClient) 
            return (processing
                and utils:callVirtualMethod(
                    raknet.pRakClient[0], 
                    "bool(__thiscall*)(void*, uintptr_t, char, char, char)", 6, 
                    pRakClient, bs, rakConst.HIGH_PRIORITY, rakConst.RELIABLE_ORDERED, 0
                )
                or raknet.originalOutgoingRpc(
                    raknet.pRakClient, bs, rakConst.HIGH_PRIORITY, rakConst.RELIABLE_ORDERED, 0
                )  
            )                                                                                     
        end

        function public:emulalteReceivePacket(id, bs)           
            if not self:isInitialized() then return false end                                                                               
            -- return raknet.originalIncomingPacket(raknet.pRakClient, bs, rakConst.HIGH_PRIORITY, rakConst.RELIABLE_ORDERED, 0)
        end
       
        function public:sendRpc(id, bs, processing)           
            if not self:isInitialized() then return false end
            local pId = ffi.new("int[1]", id) 
            local pRakClient = ffi.cast("void*", raknet.pRakClient)                                                                                               
            return (processing
                and utils:callVirtualMethod(
                    raknet.pRakClient[0], 
                    "bool(__thiscall*)(void*, int*, uintptr_t, char, char, char, bool)", 25, 
                    pRakClient, pId, bs, rakConst.HIGH_PRIORITY, rakConst.RELIABLE_ORDERED, 0, false
                )
                or raknet.originalOutgoingRpc(
                    raknet.pRakClient, pId, bs, rakConst.HIGH_PRIORITY, rakConst.RELIABLE_ORDERED, 0, false
                )
            )
        end 

        function public:emulalteReceiveRpc(id, bs)           
            if not self:isInitialized() then return false end                                                                          
            
        end
        
        function public:onSendPacket(callback)
            return private:createHandler("outgoingPacket", callback)                           
        end

        function public:onReceivePacket(callback)   
            return private:createHandler("incomingPacket", callback)                                           
        end

        function public:onSendRpc(callback)             
            return private:createHandler("outgoingRpc", callback)     
        end 

        function public:onReceiveRpc(callback)   
            return private:createHandler("incomingRpc", callback)                                     
        end
        
        function public:destroyHandlerByIndex(handlerType, iHandler)         
            local handler = raknet.handlers[handlerType]               
            if handler[iHandler] then         
                if handler then                  
                    table.remove(handler, iHandler)
                else
                    utils:warningMessage("The handler name is incorrect.")
                end
            else
                utils:warningMessage(("Handler with index: %s - does not exist."):format(iHandler))
            end
        end

        function public:getAllHandlers() 
            local handlers = raknet.handlers                     
            return setmetatable({}, {
                __index = handlers,                
                __newindex = function() utils:warningMessage("The table is not available for changes.") end,
                __pairs = function() return pairs(handlers) end,
                __len = function() return #handlers end
            })
        end

    setmetatable(public, self)
    self.__index = self
    return public
end


return IRHooks