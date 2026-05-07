local DataEnumTypes = require("./DataEnumTypes")

export type DataEnumTypes = typeof(DataEnumTypes)

export type PacketMethods<T> = {
    FireAllClients : (self : PacketMethods<T>, Data : T) -> (),
    FireClient : (self : PacketMethods<T>, Player : Player, Data : T) -> (),
    FireServer : (self : PacketMethods<T>, Data : T) -> (),
}

export type Packet<T> = {
    OnClientEvent : {
        Connect : (self : PacketMethods<T>, Callback : (Data : T) -> ()) -> ()
    },

    OnServerEvent : {
        Connect : (self : PacketMethods<T>, Callback : (Player : Player, Data : T) -> ()) -> ()
    }
} & PacketMethods<T>

export type Notwork = DataEnumTypes & {
    DefinePacket : <T>(PacketInfo : T) -> Packet<T>,
    DefineUnreliablePacket : <T>(PacketInfo : T) -> Packet<T>,

    dict : <T>(t: T) -> T,
    array : <T>({T}) -> {T},
}

return {}