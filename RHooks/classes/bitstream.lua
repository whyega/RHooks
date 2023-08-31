local ffi = require("ffi")
local utils = require("RHooks.classes.utils")
local offsets = require("RHooks.classes.offsets")


ffi.cdef[[    
    typedef struct {
        int	numberOfBitsUsed;
        int numberOfBitsAllocated;
        int readOffset;
        unsigned char *data;
        bool copyData;
        unsigned char stackData[256];
    } BitStream;
]]


local sampHandle = utils:getSampHandle()


local BitStreamInterface = {}
function BitStreamInterface:new(...)
    local public
    local private


    local BitStream = {}

    function BitStream:BitStream()
        local BitStream = ffi.new("BitStream")
        local CBitStreamBitStream = ffi.cast("uintptr_t*(__thiscall*)(BitStream *this)", (sampHandle + offsets:getAddress("CBitStreamBitStream")))
        return CBitStreamBitStream(BitStream)
    end

    function BitStream:BitStream1(data, length, unk)
        local BitStream = ffi.new("BitStream")
        local CBitStreamBitStream1 = ffi.cast("uintptr_t*(__thiscall*)(BitStream *this, uint8_t *data, unsigned int size, char unk)", (sampHandle + offsets:getAddress("CBitStreamBitStream1")))
        return CBitStreamBitStream1(BitStream, data, length, unk)
    end

    function BitStream:Write(data, size, rightAlignedBits)
        local input = ffi.cast("uint8_t*", data)
        local CBitStreamWrite = ffi.cast("void(__thiscall*)(uintptr_t *this, uint8_t *data, unsigned int size, char rightAlignedBits)", (sampHandle + offsets:getAddress("CBitStreamWrite")))
        CBitStreamWrite(private.bitstream, input, size, rightAlignedBits)
    end

    function BitStream:Write0()
        local CBitStreamWrite0 = ffi.cast("int(__thiscall*)(uintptr_t *this)", (sampHandle + offsets:getAddress("CBitStreamWrite0")))
        CBitStreamWrite0(private.bitstream)
    end

    function BitStream:Write1()
        local CBitStreamWrite1 = ffi.cast("int(__thiscall*)(uintptr_t *this)", (sampHandle + offsets:getAddress("CBitStreamWrite1")))
        CBitStreamWrite1(private.bitstream)
    end

    function BitStream:WriteCompressed(data, size, unsignedData)       
        local input = ffi.cast("uint8_t*", data)        
        local CBitStreamWriteCompressed = ffi.cast("void(__thiscall*)(uintptr_t *this, uint8_t *output, unsigned int numberOfBytes, char unsignedData)", (sampHandle + offsets:getAddress("CBitStreamWriteCompressed")))
        return CBitStreamWriteCompressed(private.bitstream, input, size, unsignedData)
    end

    function BitStream:Read(data, size)
        local output = ffi.cast("uint8_t*", data)
        local CBitStreamRead = ffi.cast("char(__thiscall*)(uintptr_t *this, uint8_t *output, unsigned int numberOfBytes)", (sampHandle + offsets:getAddress("CBitStreamRead")))
        CBitStreamRead(private.bitstream, output, size)
    end

    function BitStream:ReadCompressed(data, size, unsignedData)
        local output = ffi.cast("uint8_t*", data)
        local CBitStreamReadCompressed = ffi.cast("char(__thiscall*)(uintptr_t *this, uint8_t *output, unsigned int numberOfBytes, char unsignedData)", (sampHandle + offsets:getAddress("CBitStreamReadCompressed")))
        return CBitStreamReadCompressed(private.bitstream, output, size, unsignedData)
    end

    function BitStream:IgnoreBits(bits)
        local CBitStreamIgnoreBits = ffi.cast("int(__thiscall*)(uintptr_t *this, int numberOfBits)", (sampHandle + offsets:getAddress("CBitStreamIgnoreBits")))
        return CBitStreamIgnoreBits(private.bitstream, bits)
    end

    function BitStream:ResetWritePointer()
        local CBitStreamResetWritePointer = ffi.cast("void(__thiscall*)(uintptr_t *this)", (sampHandle + offsets:getAddress("CBitStreamResetWritePointer")))
        return CBitStreamResetWritePointer(private.bitstream)
    end

    function BitStream:ResetReadPointer()
        local CBitStreamResetReadPointer = ffi.cast("void(__thiscall*)(uintptr_t *this)", (sampHandle + offsets:getAddress("CBitStreamResetReadPointer")))
        return CBitStreamResetReadPointer(private.bitstream)
    end

    function BitStream:SetWriteOffset(offset)
        local CBitStreamSetWriteOffset = ffi.cast("int(__thiscall*)(uintptr_t *this, int offset)", (sampHandle + offsets:getAddress("CBitStreamSetWriteOffset")))
        return CBitStreamSetWriteOffset(private.bitstream, offset)
    end

    function BitStream:Reset()
        local CBitStreamReset = ffi.cast("void(__thiscall*)(uintptr_t *this)", (sampHandle + offsets:getAddress("CBitStreamReset")))
        return CBitStreamReset(private.bitstream)
    end

    function BitStream:Destructor()
        local CBitStreamDestructor = ffi.cast("char(__thiscall*)(uintptr_t *this)", (sampHandle + offsets:getAddress("CBitStreamDestructor")))
        return CBitStreamDestructor(private.bitstream)
    end


    private = {}

    local args = select("#", ...)
    if (args == 0) then
        private.bitstream = BitStream:BitStream()
    elseif (args == 1) then
        private.bitstream = ffi.cast("uintptr_t*", ...)
    elseif (args == 3) then
        private.bitstream = BitStream:BitStream1(...)
    end


    public = {}

    ---Writes an integer value of 8 bits
    ---@param data number input data
    function public:writeInt8(data)
        local input = ffi.new("int8_t[1]", data)
        BitStream:Write(input, 8, 1)
    end

    ---Writes an integer value of 16 bits
    ---@param data number input data
    function public:writeInt16(data)
        local input = ffi.new("int16_t[1]", data)
        BitStream:Write(input, 16, 1)
    end

    ---Writes an integer value of 32 bits
    ---@param data number input data
    function public:writeInt32(data)
        local input = ffi.new("int32_t[1]", data)
        BitStream:Write(input, 32, 1)
    end

    ---Writes an unsigned integer value of 8 bits
    ---@param data number input data
    function public:writeUInt8(data)
        local input = ffi.new("uint8_t[1]", data)
        BitStream:Write(input, 8, 1)
    end

    ---Writes an unsigned integer value of 16 bits
    ---@param data number input data
    function public:writeUInt16(data)
        local input = ffi.new("uint16_t[1]", data)
        BitStream:Write(input, 16, 1)
    end

    ---Writes an unsigned integer value of 32 bits
    ---@param data number input data
    function public:writeUInt32(data)
        local input = ffi.new("uint32_t[1]", data)
        BitStream:Write(input, 32, 1)
    end

    ---Writes an float value of 32 bits   
    ---@param data number input data
    function public:writeFloat(data)
        local input = ffi.new("float[1]", data)
        BitStream:Write(input, 32, 1)
    end

    ---Writes an boolean value
    ---@param toggle boolean true || false
    function public:writeBool(toggle)
        if toggle then BitStream:Write1()
        else BitStream:Write0() end
    end

    ---Writes an string value
    ---@param str string input string
    function public:writeString(str)
        local input = ffi.new("char[?]", (#str + 1), str)
        BitStream:Write(input, utils:convertBytesToBits(#str), 1)
    end

    ---Writes an string value of 8 bits
    ---@param str string input string
    function public:writeString8(str)
        self:writeInt8(#str)
        self:writeString(str)
    end

    ---Writes an string value of 16 bits
    ---@param str string input string
    function public:writeString16(str)
        self:writeInt16(#str)
        self:writeString(str)
    end

    ---Writes an string value of 32 bits
    ---@param str string input string
    function public:writeString32(str)
        self:writeInt32(#str)
        self:writeString(str)
    end

    ---Writes a buffer of the specified size
    ---@param input any input data
    ---@param size number data size
    function public:writeBuffer(input, size)
        BitStream:Write(input, utils:convertBytesToBits(size), 1)
    end

    ---Writes an array as float values
    ---@param vector table array data
    function public:writeVector(vector)
        for _, coordinate in ipairs(vector) do self:writeFloat(coordinate) end
    end

    ---Reads an integer value of 8 bits
    ---@return number output output value
    function public:readInt8()
        local output = ffi.new("int8_t[1]")
        BitStream:Read(output, 1)
        return output[0]
    end

    ---Reads an integer value of 16 bits
    ---@return number output output value
    function public:readInt16()
        local output = ffi.new("int16_t[1]")
        BitStream:Read(output, 2)
        return output[0]
    end

    ---Reads an integer value of 32 bits
    ---@return number output value
    function public:readInt32()
        local output = ffi.new("int32_t[1]")
        BitStream:Read(output, 4)
        return output[0]
    end

    ---Reads an unsigned integer value of 8 bits   
    ---@return number output output value
    function public:readUInt8()
        local output = ffi.new("uint8_t[1]")
        BitStream:Read(output, 1)
        return output[0]
    end

    ---Reads an unsigned integer value of 16 bits   
    ---@return number output output value
    function public:readUInt16()
        local output = ffi.new("uint16_t[1]")
        BitStream:Read(output, 2)
        return output[0]
    end

    ---Reads an unsigned integer value of 32 bits   
    ---@return number output output value
    function public:readUInt32()
        local output = ffi.new("uint32_t[1]")
        BitStream:Read(output, 4)
        return output[0]
    end

    ---Reads an float value of 32 bits   
    ---@return number output output value
    function public:readFloat()
        local output = ffi.new("float[1]")
        BitStream:Read(output, 4)
        return output[0]
    end

    ---Reads an boolean value 
    ---@return boolean output output value: true || false
    function public:readBool()
        local output = ffi.new("bool[1]")
        BitStream:Read(output, 1)
        return output[0]
    end

    ---Reads an string value
    ---@param size number number of bits
    ---@return string output output string
    function public:readString(size)
        local output = ffi.new("char[?]", (size + 1))
        BitStream:Read(output, size)
        return ffi.string(output)
    end

    ---Reads an string value of 8 bits    
    ---@return string output output string
    function public:readString8()
       return self:readString(self:readInt8())
    end

    ---Reads an string value of 16 bits    
    ---@return string output output string
    function public:readString16()
        return self:readString(self:readInt16())
    end

    ---Reads an string value of 32 bits    
    ---@return string output output string
    function public:readString32()
        return self:readString(self:readInt32())
    end

    ---Reads a buffer of the specified size
    ---@param output any output data
    ---@param size number data size
    ---@return any output output string
    function public:readBuffer(output, size)
        return BitStream:Read(output, size)
    end

    ---Reads an array as float values
    ---@param size number array size
    ---@return table vector output vector
    function public:readVector(size)
        local vector = {}
        for _ = 1, size do table.insert(vector, self:readFloat()) end
        return vector
    end

    ---Ignores the specified number of bits
    ---@param bits number number of bits
    ---@return number numberOfBits
    function public:ignoreBits(bits)
        return BitStream:IgnoreBits(bits)
    end

    ---Resets the write pointer
    function public:resetWritePointer()
        BitStream:ResetWritePointer()
    end

    ---Resets the read pointer
    function public:resetReadPointer()
        BitStream:ResetReadPointer()
    end

    ---Sets the offset of the write
    ---@param offset number number of bits
    ---@return number
    function public:setWriteOffset(offset)
        return BitStream:SetWriteOffset(offset)
    end

    --Sets the offset of the read
    ---@param offset number number of bits
    ---@return number
    function public:setReadOffset(offset)
        local bs = self:getStructure()
        bs.readOffset = offset
    end

    ---Returns the number of bits used
    ---@return number number of bits
    function public:getNumberOfBitsUsed()
        local bs = self:getStructure()
        return bs.numberOfBitsUsed
    end

    ---Returns the number of bytes used
    ---@return number number of bytes
    function public:getNumberOfBytesUsed()
        local bits = self:getNumberOfBitsUsed()
        return utils:convertBitsToBytes(bits)
    end

    ---Returns the number of unread bits
    ---@return number number of bits
    function public:getNumberOfUnreadBits()
        local bs = self:getStructure()
        return (bs.numberOfBitsAllocated - bs.numberOfBitsUsed)
    end

    ---Returns the number of unread bytes
    ---@return number number of bytes
    function public:getNumberOfUnreadBytes()
        local bits = self:getNumberOfUnreadBits()
        return utils:convertBitsToBytes(bits)
    end

    ---Returns the offset of the write
    ---@return number number of bits
    function public:getWriteOffset()
        local bs = self:getStructure()
        return bs.numberOfBitsUsed
    end

    ---Returns the offset of the read
    ---@return number number of bits
    function public:getReadOffset()
        local bs = self:getStructure()
        return bs.readOffset
    end

    ---Returns the pointer to data
    ---@return number pointer pointer to data
    function public:getDataPtr()
        local bs = self:getStructure()
        return utils:getPointer(bs.data)
    end

    ---Reset write and read offsets
    function public:reset()
        BitStream:Reset()
    end

    ---Deletes the BitStream object
    ---@return number result
    function public:delete()
        return BitStream:Destructor()
    end

    ---Returns a pointer to the BitStream
    ---@return number pointer BitStream pointer
    function public:getPointer()
        return utils:getPointer(private.bitstream)
    end

    ---Returns BitStream as a structure
    ---@return any BitStream BitStream struct
    function public:getStructure()
        return ffi.cast("BitStream*", private.bitstream)
    end

    ---Returns original BitStream methods
    ---@return table originalBitStream BitStream object
    function public:getBitStream()
        return BitStream
    end


    setmetatable(public, self)
    self.__index = self
    return public
end



return BitStreamInterface