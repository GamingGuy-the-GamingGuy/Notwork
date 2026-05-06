local SharedPackets = require("@game/ReplicatedStorage/SharedPackets")
local packet = SharedPackets.packet

packet:FireServer({Distance = 4, Message = "Hello!", Position = CFrame.new(0,0,0)})