--[[
    Remote event instance handlers

    Routes received data to their callbacks
    Although ^ that is less than optimal in terms of architecture, it works fine.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Serializer = require("./Serializer")

local isServer = RunService:IsServer()

local RemoteEvents = {}
RemoteEvents.Packets = {}
RemoteEvents.RemoteEvent, RemoteEvents.UnreliableRemoteEvent = nil :: RemoteEvent, nil :: UnreliableRemoteEvent

local CallbackType = isServer and "_ServerCallbacks" or "_ClientCallbacks"

-- RemoteEvent instance initializations
if RunService:IsServer() then 
    NotworkEventFolder = Instance.new("Folder")
    RemoteEvents.RemoteEvent = Instance.new("RemoteEvent")
    RemoteEvents.UnreliableRemoteEvent = Instance.new("UnreliableRemoteEvent")

    NotworkEventFolder.Name = "Notwork_Events"
    RemoteEvents.RemoteEvent.Name = "Notwork_RemoteEvent"
    RemoteEvents.UnreliableRemoteEvent.Name = "Notwork_UnreliableRemoteEvent"

    NotworkEventFolder.Parent = ReplicatedStorage
    RemoteEvents.RemoteEvent.Parent = NotworkEventFolder
    RemoteEvents.UnreliableRemoteEvent.Parent = NotworkEventFolder
else
    NotworkEventFolder = ReplicatedStorage:WaitForChild("Notwork_Events")
    RemoteEvents.RemoteEvent = NotworkEventFolder:WaitForChild("Notwork_RemoteEvent")
    RemoteEvents.UnreliableRemoteEvent = NotworkEventFolder:WaitForChild("Notwork_UnreliableRemoteEvent")
end

local function getPacket(buff : buffer)
    local id = Serializer.GetId(buff)

    return RemoteEvents.Packets[id]
end

local function genericEventListener(Player : Player, buff : buffer, references : {any})
    local packet = getPacket(buff)
    if not packet then 
        error("Cannot find original packet.")
        return 
    end
    
    local packetDataTypes = packet.PacketInfo
    
    local constructedData = Serializer.Read(buff, references, packetDataTypes)
    
    if not constructedData then 
        error("Data cannot be reconstructed for packet with info " .. packet.PacketInfo)
        return
    end
    
    for _, callback in ipairs(packet[CallbackType] or {}) do 
        if callback then
            -- Generic callback for server & client
            -- Server: (Player, constructedData)
            -- Client: (constructedData, nil)
            callback(Player or constructedData, (Player and constructedData) or nil)
        end
    end
end

local function ClientEventListener(buff : buffer, references : {any})
    genericEventListener(nil, buff, references)
end

local function ServerEventListener(Player : Player, buff : buffer, references : {any})
    genericEventListener(Player, buff, references)
end

if not isServer then 
    RemoteEvents.RemoteEvent.OnClientEvent:Connect(ClientEventListener)
    RemoteEvents.UnreliableRemoteEvent.OnClientEvent:Connect(ClientEventListener)
end

if isServer then 
    RemoteEvents.RemoteEvent.OnServerEvent:Connect(ServerEventListener) 
    RemoteEvents.UnreliableRemoteEvent.OnServerEvent:Connect(ServerEventListener)  
end

return RemoteEvents