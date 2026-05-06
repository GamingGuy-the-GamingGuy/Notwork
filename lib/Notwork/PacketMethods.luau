--[[
    Designed to be idiomatic to Roblox's RemoteEvent instances.

    Packet's do not have disconnect functions because they're intended to be static, not dynamic
    
]]

local RunService = game:GetService("RunService")

local Annotations = require("./Annotations")
local Serializer = require("./Serializer")

local isServer = RunService:IsServer()

local PacketMethods = {}
PacketMethods.__index = PacketMethods

type Packet<T> = Annotations.Packet<T>

-- Firing events

function PacketMethods.FireAllClients(self, Data : {[string] : any})
    if not isServer then 
        error("Cannot fire to clients on a client", 2)
        return
    end

    local buff, references = Serializer.Serialize(Data, self.PacketInfo, self.Id)
    if not buff then
        error("Cannot properly serialize buffer for event with ID " .. self.Id, 4)
        return
    end

    self.RemoteEvent:FireAllClients(buff, references)
end

function PacketMethods.FireClient<T>(self: Packet<T>, Player : Player, Data : Packet<T>)
    if typeof(Player) ~= "Instance" then 
        print(Data.PacketInfo)
        error("Player is not of type Instance for packet (See packet information above)")
    end

    if not isServer then 
        error("Cannot fire to the client on the client", 2)
        return
    end

    local buff, references = Serializer.Serialize(Data, self.PacketInfo, self.Id)
    if not buff then
        error("Cannot properly serialize buffer for event with ID " .. self.Id, 4)
        return
    end

    self.RemoteEvent:FireClient(Player, buff, references)
end

function PacketMethods.FireServer<T>(self: Packet<T>, Data : T)
    if isServer then 
        error("Cannot fire to the server on the server", 2)
        return
    end

    local buff, references = Serializer.Serialize(Data, self.PacketInfo, self.Id)
    if not buff then
        error("Cannot properly serialize buffer for event with ID " .. self.Id, 4)
        return
    end

    self.RemoteEvent:FireServer(buff, references)
end

function PacketMethods._OnClientEventConnect<T>(self : Packet<T>, Callback : (T) -> ())
    if isServer then 
        error("OnClientEvent can only be called on the client", 4)
        return
    end

    table.insert(self._ClientCallbacks, Callback)
end

function PacketMethods._OnServerEventConnect<T>(self : Packet<T>, Callback : (T) -> ())
    if not isServer then 
        error("OnServerEvent can only be called on the server", 4)
        return
    end

    table.insert(self._ServerCallbacks, Callback)
end

return {new = function<T>(PacketInfo : T, Event : RemoteEvent | UnreliableRemoteEvent) : Packet<T>
    local Packet = {
        PacketInfo = PacketInfo,
        RemoteEvent = Event,
        _ClientCallbacks = {},
        _ServerCallbacks = {},
    }
    
    Packet.OnClientEvent = {
        _Packet = Packet,
        Connect = function(self : typeof(Packet.OnClientEvent), Callback : () -> ())
            Packet:_OnClientEventConnect(Callback)
        end
    }
    
    Packet.OnServerEvent = {
        _Packet = Packet,
        Connect = function(self : typeof(Packet.OnServerEvent), Callback : () -> ())
            Packet:_OnServerEventConnect(Callback)
        end
    }
    
    setmetatable(Packet, {__index = PacketMethods})

    return Packet
end}
