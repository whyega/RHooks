local Utils = require("RHooks.classes.utils")


local utils = Utils:new()

local offsets = {
    game = {
        CTimerUpdate = 0x561B10
    },
    samp = {
        sampInfo = {["R1"] = 0x21A0F8, ["R2"] = 0x1, ["R3"] = 0x26e8dc, ["R4"] = 0x1, ["R5"] = 0x1},
        rakClient = {["R1"] = 0x3C9, ["R2"] = 0x1, ["R3"] = 0x2c, ["R4"] = 0x1, ["R5"] = 0x1},
        handleRpcPacket = {["R1"] = 0x372F0, ["R2"] = 0x1, ["R3"] = 0x3a6a0, ["R4"] = 0x1, ["R5"] = 0x1}
    }
}


function getOffsetFromBase(offsetName, base)
    local sampVersion = utils:getSampVersion() 
    assert((sampVersion ~= "unknown"), "This version of SA:MP has no support from the library.")
    if not base then return offsets.game[offsetName] end            
    return (base + offsets.samp[offsetName][sampVersion])
end