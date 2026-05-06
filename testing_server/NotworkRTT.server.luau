local SharedPackets = require("@game/ReplicatedStorage/SharedPackets")

SharedPackets.packet.OnServerEvent:Connect(function(Player: Player, Data: { Distance: number, Message: string, Position: Vector3 })  
    print(Data)
end)