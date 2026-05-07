--[[

]]

local Annotations = require("./Notwork/Annotations")
local DataEnumTypes = require("./Notwork/DataEnumTypes")
local PacketMethods = require("./Notwork/PacketMethods") 
local RemoteEvents = require("./Notwork/RemoteEvents")

local Notwork = {}
local Packets = {}
local CallerPaths = {}
local PacketFromId = {}
Notwork.RemoteEvent, Notwork.UnreliableRemoteEvent = RemoteEvents.RemoteEvent, RemoteEvents.UnreliableRemoteEvent

type Packet<T> = Annotations.Packet<T>

type DataTypes = Annotations.DataEnumTypes

-- Guaranteed to have no overlap between packet ID's
local function GenerateId<T>(Packet : Packet<T>)
    local callerPath = debug.info(2, "s")
    local callerIndex = table.find(CallerPaths, callerPath)

    if not callerIndex then 
        table.insert(CallerPaths, callerPath)
        callerIndex = #CallerPaths
    end

    table.insert(Packets, Packet)
    local packetIndex = #Packets

    local buff = buffer.create(4)
    buffer.writeu16(buff, 0, callerIndex)
    buffer.writeu16(buff, 2, packetIndex)

    local Id = buffer.readu32(buff, 0)

    PacketFromId[Id] = Packet
    RemoteEvents.Packets = PacketFromId

    return Id
end

local function constructPacket<T>(PacketInfo : T, Type : RemoteEvent | UnreliableRemoteEvent)
    local Packet = PacketMethods.new(PacketInfo, Type)

    local Id = GenerateId(Packet)
    Packet.Id = Id
    
    return Packet
end

function Notwork.Array(array : {keyof<DataTypes>})
    return {Name = "Array", Type = "table", Data = array}
end

function Notwork.Dict(dict : {[string] : keyof<DataTypes>})
    return {Name = "Dict", Type = "table", Data = dict}
end

function Notwork.DefinePacket<T>(PacketInfo: T): Packet<T>
    return constructPacket(PacketInfo, Notwork.RemoteEvent)
end

function Notwork.DefineUnreliablePacket<T>(PacketInfo : T)
    return constructPacket(PacketInfo, Notwork.UnreliableRemoteEvent) :: Packet<T>
end

-- construct the returned table with data types
local returnedNotwork = {
    DefinePacket = Notwork.DefinePacket, 
    DefineUnreliablePacket = Notwork.DefineUnreliablePacket,
    Array = Notwork.Array,
    Dict = Notwork.Dict,
    Struct = Notwork.Struct,
    _Packets = Notwork._Packets,
    RemoteEvent = Notwork.RemoteEvent :: RemoteEvent,
    UnreliableRemoteEvent = Notwork.UnreliableRemoteEvent :: UnreliableRemoteEvent
}

for dataTypeName, dataTypeModule in pairs(DataEnumTypes) do 
    returnedNotwork[dataTypeName] = dataTypeModule
end

return returnedNotwork :: Annotations.Notwork