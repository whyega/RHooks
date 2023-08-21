local ffi = require("ffi")


local Utils = {}
function Utils:new()
    local public


    public = {}

    function public:getSampHandle()
        return getModuleHandle("samp.dll")
    end
    function public:getSampVersion()
        local version = "unknown"
        local versions = {
            [0x31DF13] = "R1",
            [0x3195DD] = "R2",
            [0xCC4D0] = "R3",
            [0xCBCB0] = "R4",
            [0xCBC90] = "R5",
        }

        local handle = self:getSampHandle()
        if handle then
            local e_lfanew = ffi.cast("long*", (handle + 60))
            local ntHeader = (handle + e_lfanew[0])
            local pEntryPoint = ffi.cast("unsigned int*", (ntHeader + 40))
            if versions[pEntryPoint[0]] then
                version = versions[pEntryPoint[0]]
            end
        end
        return version
    end

    function public:getPointer(p)
        return tonumber(ffi.cast("intptr_t", p))
    end

    function public:callVirtualMethod(vt, prototype, method, ...)
        local virtualTable = ffi.cast("intptr_t**", vt)[0]
        return ffi.cast(prototype, virtualTable[method])(...)
    end

    function public:warningMessage(msg)
        print(("[RHooks] %s"):format(msg))
    end

    function public:errorMessage(reason, msg)
        local val = assert(reason, ("[RHooks] %s"):format(msg))
        return val
    end


    setmetatable(public, self)
    self.__index = self
    return public
end



return Utils:new()