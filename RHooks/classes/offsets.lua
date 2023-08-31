local utils = require("RHooks.classes.utils")


local Offsets = {}
function Offsets:new()
    local public
    local private


    private = {}

    private.addresses = {
        CTimerUpdate = 0x561B10,

        CNetGame = {["DLR1"] = 0x2ACA24, ["R1"] = 0x21A0F8, ["R2"] = 0x21A100, ["R3"] = 0x26E8DC, ["R4"] = 0x26EA0C, ["R5"] = 0x26EB94},

        CRakPeerSend = {["DLR1"] = 0x3BE90, ["R1"] = 0x388E0, ["R2"] = 0x389C0, ["R3"] = 0x3BC90, ["R4"] = 0x3C380, ["R5"] = 0x3C3D0},
        CRakPeerReceive = {["DLR1"] = 0x40A90, ["R1"] = 0x3D4E0, ["R2"] = 0x3D5C0, ["R3"] = 0x40890, ["R4"] = 0x40A90, ["R5"] = 0x40FD0},
        CRakPeerRPC = {["DLR1"] = 0x3A1E0, ["R1"] = 0x36C30, ["R2"] = 0x36D10, ["R3"] = 0x39FE0, ["R4"] = 0x3A6D0, ["R5"] = 0x3A720},
        CRakPeerHandleRPCPacket = {["DLR1"] = 0x3A8A0, ["R1"] = 0x372F0, ["R2"] = 0x373D0, ["R3"] = 0x3A6A0, ["R4"] = 0x3AD90, ["R5"] = 0x3ADE0},
        ProcessNetworkPacket = {["DLR1"] = 0x1, ["R1"] = 0x3B950, ["R2"] = 0x1, ["R3"] = 0x1, ["R4"] = 0x1F6E0, ["R5"] = 0x1},

        CRakPeerReceiveIgnoreRPC = {["DLR1"] = 0x40350, ["R1"] = 0x3CDA0, ["R2"] = 0x3CE80, ["R3"] = 0x40150, ["R4"] = 0x40840, ["R5"] = 0x40890},
        CRakPeerAddPacketToProducer = {["DLR1"] = 0x3AB50, ["R1"] = 0x375A0, ["R2"] = 0x37680, ["R3"] = 0x3A950, ["R4"] = 0x3B040, ["R5"] = 0x3B090},
        AllocPacket = {["DLR1"] = 0x37DB0, ["R1"] = 0x34800, ["R2"] = 0x348E0, ["R3"] = 0x37BB0, ["R4"] = 0x382A0, ["R5"] = 0x382F0},
        CRakPeerDeallocatePacket = {["DLR1"] = 0x1, ["R1"] = 0x34AC0, ["R2"] = 0x1, ["R3"] = 0x1, ["R4"] = 0x1, ["R5"] = 0x1},

        CBitStreamBitStream = {["DLR1"] = 0x1F1F0, ["R1"] = 0x1BC40, ["R2"] = 0x1BD20, ["R3"] = 0x1EFF0, ["R4"] = 0x1F6E0, ["R5"] = 0x1F730},
        CBitStreamBitStream1 = {["DLR1"] = 0x1F280, ["R1"] = 0x1BCD0, ["R2"] = 0x1BDB0, ["R3"] = 0x1F080, ["R4"] = 0x1F770, ["R5"] = 0x1F7C0},
        CBitStreamDestructor = {["DLR1"] = 0x1F390, ["R1"] = 0x1BDE0, ["R2"] = 0x1BEC0, ["R3"] = 0x1F190, ["R4"] = 0x1F880, ["R5"] = 0x1F8D0},
        CBitStreamWrite = {["DLR1"] = 0x1FB50, ["R1"] = 0x1C4F0, ["R2"] = 0x1C680, ["R3"] = 0x1F950, ["R4"] = 0x20040, ["R5"] = 0x20090},
        CBitStreamWrite0 = {["DLR1"] = 0x1F9D0, ["R1"] = 0x1C420, ["R2"] = 0x1C500, ["R3"] = 0x1F7D0, ["R4"] = 0x1FEC0, ["R5"] = 0x1FF10},
        CBitStreamWrite1 = {["DLR1"] = 0x1F9F0, ["R1"] = 0x1C440, ["R2"] = 0x1C520, ["R3"] = 0x1F7F0, ["R4"] = 0x1FEE0, ["R5"] = 0x1FF30},
        CBitStreamWriteCompressed = {["DLR1"] = 0x1FBF0, ["R1"] = 0x1C640, ["R2"] = 0x1C720, ["R3"] = 0x1F9F0, ["R4"] = 0x200E0, ["R5"] = 0x20130},
        CBitStreamRead = {["DLR1"] = 0x1F960, ["R1"] = 0x1C3B0, ["R2"] = 0x1C490, ["R3"] = 0x1F760, ["R4"] = 0x1FE50, ["R5"] = 0x1FEA0},
        CBitStreamReadCompressed = {["DLR1"] = 0x1F530, ["R1"] = 0x1BF80, ["R2"] = 0x1C060, ["R3"] = 0x1F330, ["R4"] = 0x1FA20, ["R5"] = 0x1FA70},
        CBitStreamIgnoreBits = {["DLR1"] = 0x1F7B0, ["R1"] = 0x1C200, ["R2"] = 0x1C2E0, ["R3"] = 0x1F5B0, ["R4"] = 0x1FCA0, ["R5"] = 0x1FCF0},
        CBitStreamResetWritePointer = {["DLR1"] = 0x1F3D0, ["R1"] = 0x1BE20, ["R2"] = 0x1BF00, ["R3"] = 0x1F1D0, ["R4"] = 0x1F8C0, ["R5"] = 0x1F910},
        CBitStreamResetReadPointer = {["DLR1"] = 0x1F3C0, ["R1"] = 0x1BE10, ["R2"] = 0x1BEF0, ["R3"] = 0x1F1C0, ["R4"] = 0x1F8B0, ["R5"] = 0x1F900},
        CBitStreamSetWriteOffset = {["DLR1"] = 0x1F7C0, ["R1"] = 0x1C210, ["R2"] = 0x1C2F0, ["R3"] = 0x1F5C0, ["R4"] = 0x1FCB0, ["R5"] = 0x1FD00},
        CBitStreamReset = {["DLR1"] = 0x1F3B0, ["R1"] = 0x1BE00, ["R2"] = 0x1BEE0, ["R3"] = 0x1F1B0, ["R4"] = 0x1F8A0, ["R5"] = 0x1F8F0},
    }


    public = {}

    function public:getAddress(name, isGtaOffset)
        if isGtaOffset then return utils:errorMessage(private.addresses[name], ("Attempt to get a non-existent key: %s"):format(name)) end
        local sampVersion = utils:getSampVersion()
        utils:errorMessage(private.addresses[name][sampVersion], "The version of the SAMP used is not supported")
        return utils:errorMessage(private.addresses[name][sampVersion], ("Attempt to get a non-existent key: %s"):format(name))
    end


    setmetatable(public, self)
    self.__index = self
    return public
end



return Offsets:new()