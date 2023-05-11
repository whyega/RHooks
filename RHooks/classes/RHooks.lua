require("SFlua.const")
local raknet = require("RHooks.hooks")

local RHooks = {}
function RHooks:new()        
    local public
    local private
    private = {}        

    public = {}
        function public:isInitialized()
            return (raknet.pRakClient and raknet.pRakPeer)
        end

        function public:sendRpc(id, bs)           
            if not public:isInitialized() then return false end            
            print("raknet: ", raknet.pRakClient, raknet.pRakPeer)                                  
            -- return raknet.originalOutgoingRpc(RakClient, id, bs, HIGH_PRIORITY, RELIABLE_ORDERED, 0, false)
        end

        function public:registerHandler(callback)
            if not public:isInitialized() then return false end 
            
        end

    setmetatable(public, self)
    self.__index = self
    return public
end


return RHooks