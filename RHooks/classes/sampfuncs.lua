local SampFuncs = {}
function SampFuncs:new()        
    local public
    local private
    private = {}        

    public = {}
       

    setmetatable(public, self)
    self.__index = self
    return public
end


return SampFuncs