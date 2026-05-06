--[[
    Unsure if ByteNet uses a similar system (information in BuffWriter why this is relevant)
    Reads buffer that is assigned in BuffWriter.Read() and reconstructs it in the Serializer 
]]

local BuffWriter = {}

cursor = nil :: number
buff = nil :: buffer
references = nil :: { [number] : unknown }

function BuffWriter.u8()
    local val = buffer.readu8(buff, cursor)
    cursor += 1
    
    return val
end

function BuffWriter.u16()
    local val = buffer.readu16(buff, cursor)
    cursor += 2
    
    return val
end

function BuffWriter.u32()
    local val = buffer.readu32(buff, cursor)
    cursor += 4
    
    return val
end

function BuffWriter.i8()
    local val = buffer.readi8(buff, cursor)
    cursor += 1
    
    return val
end

function BuffWriter.i16()
    local val = buffer.readi16(buff, cursor)
    cursor += 2
    
    return val
end

function BuffWriter.i32()
    local val = buffer.readi32(buff, cursor)
    cursor += 4
    
    return val
end

function BuffWriter.f32()
    local val = buffer.readf32(buff, cursor)
    cursor += 4
    
    return val
end

function BuffWriter.f64()
    local val = buffer.readf64(buff, cursor)
    cursor += 8

    return val
end

function BuffWriter.vector3(value : Vector3)
    local x = buffer.readf32(buff, cursor)
    local y = buffer.readf32(buff, cursor + 4)
    local z = buffer.readf32(buff, cursor + 8)
    cursor += 12

    return Vector3.new(x, y, z)
end

function BuffWriter.vector2(value : Vector2)
    local x = buffer.readf32(buff, cursor)
    local y = buffer.readf32(buff, cursor + 4)
    cursor += 8

    return Vector2.new(x, y)
end

function BuffWriter.vector2int16(value : Vector2int16)
    local x = buffer.readi16(buff, cursor)
    local y = buffer.readi16(buff, cursor + 2)
    cursor += 4

    return Vector2int16.new(x, y)
end

function BuffWriter.vector3int16()
    local x = buffer.readi16(buff, cursor)
    local y = buffer.readi16(buff, cursor + 2)
    local z = buffer.readi16(buff, cursor + 4)
    cursor += 6

    return Vector3int16.new(x, y, z)
end

function BuffWriter.cframe()
    local x = buffer.readf32(buff, cursor)
    local y = buffer.readf32(buff, cursor + 8)
    local z = buffer.readf32(buff, cursor + 16)
    local r00 = buffer.readf32(buff, cursor + 24)
    local r01 = buffer.readf32(buff, cursor + 32)
    local r02 = buffer.readf32(buff, cursor + 40)
    local r10 = buffer.readf32(buff, cursor + 48)
    local r11 = buffer.readf32(buff, cursor + 56)
    local r12 = buffer.readf32(buff, cursor + 64)
    local r20 = buffer.readf32(buff, cursor + 72)
    local r21 = buffer.readf32(buff, cursor + 80)
    local r22 = buffer.readf32(buff, cursor + 88)
    cursor += 96

    return CFrame.new(x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
end

function BuffWriter.Reference()
    local index = buffer.readu8(buff, cursor)
    local val = references and references[index]
    cursor += 1

    return val
end

function BuffWriter.bool()
    local val = buffer.readu8(buff, cursor)
    cursor += 1

    if val == 1 then 
        return true
    else
        return false 
    end
end

function BuffWriter.string()
    local len = buffer.readu16(buff, cursor)

    local val = buffer.readstring(buff, cursor + 2, len)
    cursor += #val + 2
    
    return val
end

function BuffWriter.udim()
    local Offset = buffer.readf32(buff, cursor)
    local Scale = buffer.readf32(buff, cursor + 4)
    cursor += 8

    return UDim.new(Scale, Offset)
end

function BuffWriter.udim2()
    local xScale = buffer.readf32(buff, cursor)
    local xOffset = buffer.readf32(buff, cursor + 4)
    local yScale = buffer.readf32(buff, cursor + 8)
    local yOffset = buffer.readf32(buff, cursor + 12)

    cursor += 16

    return UDim2.new(xScale, xOffset, yScale, yOffset)
end

function BuffWriter.Read(Buff : buffer, References : {any}, reader : () -> ())
    -- bytes 0-3 is the ID, skips to 4 for data
    cursor = 4
    buff = Buff
    references = References

    reader()

    -- Data is constructed in module Serializer
end

return BuffWriter