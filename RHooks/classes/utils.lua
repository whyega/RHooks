local ffi = require("ffi")
local bit = require("bit")


local Utils = {}
function Utils:new()
    local public


    public = {}

    function public:getSampHandle()
        return getModuleHandle("samp.dll")
    end

    function public:getSampVersion()
        local version = "unknown"
        local versions = {[0xFDB60] = "DLR1", [0x31DF13] = "R1", [0x3195DD] = "R2", [0xCC4D0] = "R3", [0xCBCB0] = "R4", [0xCBC90] = "R5"}
        local handle = self:getSampHandle()
        if handle then
            local e_lfanew = ffi.cast("long*", (handle + 60))
            local ntHeader = (handle + e_lfanew[0])
            local pEntryPoint = ffi.cast("uintptr_t*", (ntHeader + 40))
            local currentVersion = versions[pEntryPoint[0]]
            if currentVersion then version = currentVersion end
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

    function public:convertBitsToBytes(bits)
        return bit.rshift(bits + 7, 3)
    end

    function public:convertBytesToBits(bytes)
        return bit.lshift(bytes, 3)
    end


    setmetatable(public, self)
    self.__index = self
    return public
end



return Utils:new()