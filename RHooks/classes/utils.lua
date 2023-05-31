local ffi = require("ffi")

local Utils = {}
function Utils:new()        
    local public
    local private
    private = {}        

    public = {}
        function public:callVirtualMethod(vt, prototype, method, ...) 
            local cast = ffi.cast                       
            local virtualTable = cast("intptr_t**", vt)[0]       
            return cast(prototype, virtualTable[method])(...)
        end

        function public:getPointer(cdata)
            return tonumber(ffi.cast("uintptr_t", ffi.cast("void *", cdata)))
        end

        function public:getSampVersion()            
            local version = "unknown"
            local versions = {
                ["3268371"] = "R1",
                ["3249629"] = "R2", 
                ["836816"] = "R3",
                ["834736"] = "R4",
                ["1039200"] = "R5",
            }

            local handle = getModuleHandle("samp.dll")
            if handle then                
                local e_lfanew = ffi.cast("long*", (handle + 60))[0]
                local ntHeader = (handle + e_lfanew)
                local pEntryPoint = tostring(ffi.cast("unsigned int*", (ntHeader + 40))[0])               
                if versions[pEntryPoint] then                  
                    version = versions[pEntryPoint] 
                end
            end
            return version
        end

        function public:warningMessage(msg)            
            print(("[RHooks] %s"):format(msg)) 
        end

    setmetatable(public, self)
    self.__index = self
    return public
end

return Utils:new()