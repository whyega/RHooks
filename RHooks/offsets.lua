local utils = require("RHooks.classes.utils")


local offsets = {
    game = {
        CTimerUpdate = 0x561B10
    },
    samp = {
        sampInfo = {R1 = 0x21A0F8, R2 = 0x1, R3 = 0x26e8dc, R4 = 0x1, R5 = 0x1},
        rakClient = {R1 = 0x3C9, R2 = 0x1, R3 = 0x2c, R4 = 0x1, R5 = 0x1},
        handleRpcPacket = {R1 = 0x372F0, R2 = 0x1, R3 = 0x2c, R4 = 0x1, R5 = 0x1}
    }
}


function getOffsetFromBase(offsetName, base)
    if not base then return offsets.game[offsetName] end
    local sampVersion = utils:getSampVersion()
    assert((sampVersion ~= "unknown"), "Данная версия SA:MP не имеет поддержки со стороны библиотеки.")     
    return (base + offsets.samp[offsetName][sampVersion])
end