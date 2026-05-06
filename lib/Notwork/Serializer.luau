--[[
    Designed for writing & reading buffers

    Serialization functions are called by the PacketMethods
]]

local BuffReader = require("./BuffReader")
local BuffWriter = require("./BuffWriter")

type DataType = {Name : string, Type : string, Schema : {string}}

local Serialize = {}

function Serialize.GetId(buff : buffer)
    -- first 4 bytes of a buffer is ALWAYS the ID.
    return buffer.readu32(buff, 0)
end

function Serialize.Serialize(Data : {[string] : Vector3}, PacketDataTypes : {[string] : DataType}, Id : number) : buffer?
    local function writer()
        for Name : string, dataType : DataType in pairs(PacketDataTypes) do
            local dataTypeName = dataType.Name
            local dataValue = Data[Name]

            -- The function in BuffWriter that adds it to the buffer
            -- Name is a bit misleading and thought to clarify
            local writtenVal = BuffWriter[dataTypeName]

            if writtenVal then 
                local success, err = pcall(writtenVal, dataValue)

                if not success then 
                    -- error diagnostics

                    warn(err)

                    if typeof(dataValue) ~= dataType.Type then 
                        error(Name .. " is of type " .. typeof(dataValue) .. " when expected type is " .. dataType.Type, 4)
                    else
                        error(dataValue .. " (" .. typeof(dataValue) .. ")" .. " is not a proper type of " .. dataType.Name, 4)
                    end
                end
            else
                error("Packet has insufficient data for " .. Name .. ". Are you sure it is of type " .. dataTypeName .. "?", 4)
                return
            end

        end
    end

    -- Size 2 & buffer create 2 for ID allocation in the buffWriter
    local channel = BuffWriter.Write({Cursor = 0, References = {}, Size = 2, buff = buffer.create(2)}, writer, Id, Data)

    return channel.buff, channel.References
end

function Serialize.Read(buff : buffer, references : {any}, packetDataTypes : {[string] : {Name : string}})
    local data = {}

    BuffReader.Read(buff, references, function()  
        for ItemName : string, DataTbl : {Name : string} in pairs(packetDataTypes) do
            -- the corresponding function in BuffReader depending on DataType
            local readFunc = BuffReader[DataTbl.Name]
            if readFunc then
                local value : any = readFunc()
                if value == nil then 
                    error("Value cannot be found for " .. ItemName .. " when expected " .. DataTbl.Name, 2)
                    return
                end

                data[ItemName] = value
            end
        end
    end)

    return data :: {[string] : any}
end

return Serialize