local ffi = require("ffi")
local bs = require("SFlua.bitstream")
local utils = require("RHooks.classes.utils")


local BitStream = {}
function BitStream:new() -- To do      
    local public
    local private
    private = {}                                 

    public = {}
        function public:raknetNewBitStream()
            local bitstream = bs()            
            return utils:getPointer(bitstream)
        end

        function public:raknetDeleteBitStream(bitstream) -- need a FIX
            bitstream = ffi.cast("struct SFL_BitStream*", bitstream)
            bitstream:__gc()
        end
        
        function public:raknetBitStreamWriteInt8(bitstream, value)
            bitstream = ffi.cast("struct SFL_BitStream*", bitstream)
            local buf = ffi.new("char[?]", 1, value)
            bitstream:WriteBits(buf, 8, true)
        end

        function public:raknetBitStreamWriteString(bitstream, str)
            bitstream = ffi.cast("struct SFL_BitStream*", bitstream)
            local buf = ffi.new("char[?]", #str + 1, str)
            bitstream:WriteBits(buf, #str * 8, true)
        end

    setmetatable(public, self)
    self.__index = self
    return public
end


return BitStream:new()