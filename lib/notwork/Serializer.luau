--[[
    Designed for writing & reading buffers

    Serialization functions are called by the PacketMethods
]]

local BuffReader = require("./BuffReader")
local BuffWriter = require("./BuffWriter")

type DataType = {Name : string, Type : string, Data : {any}?}

local Serialize = {}

function Serialize.GetId(buff : buffer)
    -- first 4 bytes of a buffer is ALWAYS the ID.
    return buffer.readu32(buff, 0)
end

function Serialize.Serialize(Data : {[any] : any}, PacketDataTypes : {[any] : DataType}, Id : number) : buffer?
    local function writer(schema : {[any] : DataType}, data : {[any] : any})
        for Name : string, DataTbl : DataType in pairs(schema) do
            local dataTypeName = DataTbl.Name
            local dataValue = data[Name]

            -- TODO: Not hardcode Array's and Dict's (? please)
            -- and make it so it uses ipairs lol all the performance gain down the drain 👎

            if dataTypeName == "Array" or DataTbl.Name == "Dict" then
                -- recurse into both schema AND the nested data
                writer(DataTbl.Data, dataValue)
                continue
            end

            local valWritter = BuffWriter[dataTypeName]

            if valWritter then
                local success, err = pcall(valWritter, dataValue)

                if not success then 
                    -- error diagnostics

                    warn(err)
                    if typeof(dataValue) ~= DataTbl.Type then 
                        error(Name .. " is of type " .. typeof(dataValue) .. " when expected type is " .. DataTbl.Type, 4)
                    else
                        error(dataValue .. " (" .. typeof(dataValue) .. ")" .. " is not a proper type of " .. dataTypeName, 4)
                    end
                end
            else
                error("Packet has insufficient data for " .. Name .. ". Are you sure it is of type " .. dataTypeName .. "?", 4)
                return
            end

        end
    end

    -- Size 2 & buffer create 2 for ID allocation in the buffWriter
    local channel = BuffWriter.Write({Cursor = 0, References = {}, Size = 2, buff = buffer.create(2)}, Id, Data, function()  
        writer(PacketDataTypes, Data)
    end)

    return channel.buff, channel.References
end

function Serialize.Read(buff : buffer, references : {any}, packetDataTypes : {[string] : {Name : string}})
    local constructedData = {}

    local function reader(schema : {[any] : DataType}, output : {[any] : any})
        for Name : string, DataTbl : DataType in pairs(schema) do
            if DataTbl.Name == "Array" or DataTbl.Name == "Dict" then
                local nestedTable = {}

                output[Name] = nestedTable

                reader(DataTbl.Data, nestedTable)
                continue
            end

            local readFunc = BuffReader[DataTbl.Name]

            if readFunc then
                local value : any = readFunc()

                if value == nil then
                    error("Value cannot be found for " .. Name .. " when expected " .. DataTbl.Name, 2)
                    return
                end

                output[Name] = value
            end
        end
    end

    BuffReader.Read(buff, references, function()  
        reader(packetDataTypes, constructedData)
    end)

    return constructedData :: {[string] : any}
end

return Serialize