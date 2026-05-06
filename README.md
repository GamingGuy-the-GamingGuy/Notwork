<p align="center">
  Notwork
</p>

A lightweight networking library for Roblox that provides **typed remote events with schema-based serialization and efficient buffer encoding**.

---

## Features

- Strongly typed remote events
- Schema-based data validation
- Automatic serialization via buffers
- Smaller payloads compared to raw tables
- Shared definitions between client and server
- Simple event-driven API
- Support for Roblox types (Vector3, CFrame, etc.)

---

## Installation

Place `Notwork` in a shared location (e.g. `ReplicatedStorage`) and require it on both client and server.

Shared Packet Definition
```lua
local Notwork = require(path.to.Notwork)

local Packets = {}

--Define a packet once and use it on both client and server.
Packets.Packet = Notwork.DefinePacket({
    Foo = Notwork.string,
    Foo2 = Notwork.vector3
})

return Packets
```

Server Example
```lua
local Packets = require(path.to.SharedPackets)

local Packet = Packets.Packet

Packet.OnClientEvent:Connect(function(player, data)
    print("Received from client:", data)

    Packet:FireAllClients({
        Foo = "Hello from the Server!",
        Foo2 = Vector3.new(0, -5, 25)
    })
end)
```

Client Example
```lua
local Packets = require(path.to.SharedPackets)

local Packet = Packets.Packet

Packet.OnServerEvent:Connect(function(data)
    print("Received from server:", data)
end)

Packet:FireServer({
    Foo = "Hello from the Client!",
    Foo2 = Vector3.new(0, 5, 0)
})
```

## API

Packet Constructors
```lua
local Notwork = require(path.to.Notwork)

-- Uses the reliable remote event
-- Creates a typed network packet using a schema definition.
Notwork.DefinePacket(schema: {[string] : Notwork.DataType}) -> (Packet)

-- Uses the unreliable remote event
-- Creates a typed network packet using a schema definition.
Notwork.DefineUnreliablePacket(schema: {[string] : Notwork.DataType}) -> (Packet)

--Example:
local ReliablePacket = Notwork.DefinePacket({
    Foo = Notwork.string,
    Foo2 = Notwork.vector3
})

local UnreliablePacket = Notwork.DefineUnreliablePacket({
    Foo = Notwork.string,
    Foo2 = Notwork.vector3
})
```

Packet Methods
```lua
local Packet = require(path.to.SharedPackets).Packet

-- Data has type annotations with intellisense, allowing you to see data types based on the packet.

-- Can only be called from the client
Packet:FireServer(Data: {[string]: any})

-- Can only be called from the server
Packet:FireClient(Player: Player, Data : {[string]: any})
Packet:FireAllClients({Data : {[string]: any})
```

Packet Events

```lua
local Packet = require(path.to.SharedPackets).Packet

-- Can only be listened to on the server
Packet.OnServerEvent:Connect(function(Player: Player, Data: {[string]: any})

-- Can only be listened to on the client
Packet.OnClientEvent:Connect(function(Player: Player, Data: {[string]: any})

```

# How It Works

Notwork serializes structured Lua tables into compact binary buffers before sending them over Roblox RemoteEvents.

This provides:

- Reduced network payload size

- Faster replication of structured data

- Strict schema validation

- Consistent type handling between client and server

Instead of sending raw tables, data is encoded into a compact buffer format and decoded on the receiving side using the shared schema.

## Why not just use RemoteEvents?

Roblox RemoteEvents are flexible, but:

- No type safety

- No schema validation

- Larger serialized payloads

- No enforced structure

Notwork adds a thin layer over RemoteEvents that introduces:

- Typed schemas

- Automatic serialization

- Structured event APIs

- Safer networking patterns

## Supported Types
Notwork.string

Notwork.number

Notwork.any

Notwork.bool

Notwork.f32

Notwork.f64

Notwork.i8

Notwork.i16

Notwork.i32

Notwork.u16

Notwork.u32

Notwork.instance

Notwork.vector2

Notwork.vector2int16

Notwork.vector3

Notwork.vector3int16

Notwork.udim

Notwork.udim2

Notwork.cframe

## Design Philosophy

Notwork is designed to:

- Stay close to Roblox primitives

- Avoid unnecessary abstraction

- Prioritize performance and clarity

# Notes
Always define packets in a shared module

Keep schemas consistent between client and server

Notwork is not designed for dynamic event connections, i.e Disconnections or Packet's being created at runtime
