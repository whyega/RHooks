local utils = require("RHooks.classes.utils")


local Offsets = {}
function Offsets:new()
    local public
    local private


    private = {}

    private.addresses = {
        CTimerUpdate = 0x561B10,
        CNetGame = {["R1"] = 0x21A0F8, ["R3"] = 0x26E8DC, ["R5"] = 0x26EB94},
        CRakPeerSend = {["R1"] = 0x388E0, ["R3"] = 0x33BA0, ["R5"] = 0x3C3D0},
        CRakPeerReceive = {["R1"] = 0x3D4E0, ["R3"] = 0x40890, ["R5"] = 0x40FD0},
        CRakPeerRPC = {["R1"] = 0x36C30, ["R3"] = 0x33EE0, ["R5"] = 0x3A720},
        CRakPeerHandleRPCPacket = {["R1"] = 0x372F0, ["R3"] = 0x3A6A0, ["R5"] = 0x3ADE0},
        CRakPeerReceiveIgnoreRPC = {["R1"] = 0x3CDA0},
        CRakPeerDeallocatePacket = {["R1"] = 0x34AC0}
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