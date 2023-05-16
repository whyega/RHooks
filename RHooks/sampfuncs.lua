-- оепемеярх б йкюяяш

local RHooks
local sampfuncs = {}


function sampfuncs:setClass(class)    
    RHooks = class:new()
end

function sampfuncs.raknetSendRpc(id, bs)    
    return RHooks:sendRpc(id, bs)
end


return sampfuncs