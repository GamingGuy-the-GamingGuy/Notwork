--[[
    Basically identical to ByteNet's bufferWriter
]]

local BuffWriter = {}

Size = nil :: number
cursor = nil :: number
buff = nil :: buffer
references = nil :: { [number] : unknown }

local bufferCopy = buffer.copy
local bufferCreate = buffer.create

local function Allocate(Bytes : number)
	if cursor + Bytes <= Size then
		return
	end

	while cursor + Bytes > Size do
		Size *= 2
	end

	local newBuffer = bufferCreate(Size)
	bufferCopy(newBuffer, 0, buff)

	buff = newBuffer
end

local function DynamicAllocate(Bytes : number)
	while cursor + Bytes >= Size do
		Size *= 2
	end

	local newBuffer = buffer.create(Size)
	buffer.copy(newBuffer, 0, buff)

	buff = newBuffer
end

Allocate = Allocate
dyn_Allocateate = DynamicAllocate

function BuffWriter.i8(value : number)
	Allocate(1)
	buffer.writei8(buff, cursor, value)
	cursor += 1
end

function BuffWriter.i16(value : number)
	Allocate(2)
	buffer.writei16(buff, cursor, value)
	cursor += 2
end

function BuffWriter.i32(value : number)
	Allocate(4)
	buffer.writei32(buff, cursor, value)
	cursor += 4
end

function BuffWriter.u8(value : number)
	Allocate(1)
	buffer.writeu8(buff, cursor, value)
	cursor += 1
end

function BuffWriter.u16(value : number)
	Allocate(2)
	buffer.writeu16(buff, cursor, value)
	cursor += 2
end

function BuffWriter.u32(value : number)
	Allocate(4)
	buffer.writeu32(buff, cursor, value)
	cursor += 4
end

function BuffWriter.f32(value : number)
	Allocate(4)
	buffer.writef32(buff, cursor, value)
	cursor += 4
end

function BuffWriter.f64(value : number)
	Allocate(8)
	buffer.writef64(buff, cursor, value)
	cursor += 8
end

-- first 2 bytes is ALWAYS the length of the string
function BuffWriter.string(value : string)
    local length = value:len()
    -- +2 for ID
    Allocate(length + 2)

    -- id 
    buffer.writeu16(buff, cursor, length)
    cursor += 2

	buffer.writestring(buff, cursor, value)
	cursor += length
end

function BuffWriter.udim(value : UDim)
    Allocate(8)

    buffer.writef32(buff, cursor, value.Offset)
    buffer.writef32(buff, cursor + 4, value.Scale)
    cursor += 8
end

function BuffWriter.udim2(value : UDim2)
    Allocate(16)
    

    buffer.writef32(buff, cursor, value.X.Scale)
    buffer.writef32(buff, cursor + 4, value.X.Offset)
    buffer.writef32(buff, cursor + 8, value.Y.Scale)
    buffer.writef32(buff, cursor + 12, value.Y.Offset)

    cursor += 16
end

function BuffWriter.vector3(value : Vector3)
    Allocate(12)
    buffer.writef32(buff, cursor, value.x)
    buffer.writef32(buff, cursor + 4, value.y)
    buffer.writef32(buff, cursor + 8, value.z)
    cursor += 12
end

function BuffWriter.vector2(value : Vector2)
    Allocate(8)
    buffer.writef32(buff, cursor, value.x)
    buffer.writef32(buff, cursor + 4, value.y)
    cursor += 8
end

function BuffWriter.vector2int16(value : Vector2int16)
    Allocate(4)
    buffer.writei16(buff, cursor, value.X)
    buffer.writei16(buff, cursor + 2, value.Y)
    cursor += 4
end

function BuffWriter.vector3int16(value : Vector3int16)
    Allocate(6)
    buffer.writei16(buff, cursor, value.X)
    buffer.writei16(buff, cursor + 2, value.Y)
    buffer.writei16(buff, cursor + 4, value.Z)
    cursor += 6
end

function BuffWriter.cframe(value : CFrame)
    Allocate(96)

    local x, y, z,
        r00, r01, r02,
        r10, r11, r12,
        r20, r21, r22 = value:GetComponents()

    buffer.writef32(buff, cursor, x)
    buffer.writef32(buff, cursor + 8, y)
    buffer.writef32(buff, cursor + 16, z)
    buffer.writef32(buff, cursor + 24, r00)
    buffer.writef32(buff, cursor + 32, r01)
    buffer.writef32(buff, cursor + 40, r02)
    buffer.writef32(buff, cursor + 48, r10)
    buffer.writef32(buff, cursor + 56, r11)
    buffer.writef32(buff, cursor + 64, r12)
    buffer.writef32(buff, cursor + 72, r20)
    buffer.writef32(buff, cursor + 80, r21)
    buffer.writef32(buff, cursor + 88, r22)
    cursor += 96
end

function BuffWriter.Reference(value : any)
	table.insert(references, value)
	local index = #references

    Allocate(1)
	buffer.writeu8(buff, cursor, index)
	cursor += 1
end

function BuffWriter.bool(value : boolean)
	Allocate(1)
	buffer.writeu8(buff, cursor, (value == true and 1 or value == false and 0) or nil)
	cursor += 1
end

function BuffWriter.array(value : {any})
    
end

function BuffWriter.copy(value)
	buffer.copy(buff, cursor, value)
	cursor += buffer.len(value)
end

function BuffWriter.Write(Channel : {Size : number, Cursor : number, References : {}, buff : buffer}, Id : number, Data : {}, writer : () -> ())
    Size = Channel.Size
    cursor = Channel.Cursor
    references = Channel.References
    buff = Channel.buff

    Allocate(4)
    buffer.writeu32(buff, 0, Id)
    cursor += 4

    writer()

    Channel.Size = Size
    Channel.Cursor = cursor
    Channel.References = references
    Channel.buff = buff

    return Channel
end

return BuffWriter