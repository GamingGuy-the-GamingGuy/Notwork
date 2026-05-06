local Notwork = require("./Notwork")
local module = {}

module.packet = Notwork.DefinePacket({
    Position = Notwork.cframe,
    Message = Notwork.string,
    Distance = Notwork.i32
})

return module