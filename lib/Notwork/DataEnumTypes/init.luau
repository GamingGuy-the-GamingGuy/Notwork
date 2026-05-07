local _any = require("./DataEnumTypes/_any")
local _bool = require("./DataEnumTypes/_bool")
local _cframe = require("./DataEnumTypes/_cframe")
local _f32 = require("./DataEnumTypes/_f32")
local _f64 = require("./DataEnumTypes/_f64")
local _i16 = require("./DataEnumTypes/_i16")
local _i32 = require("./DataEnumTypes/_i32")
local _i8 = require("./DataEnumTypes/_i8")
local _instance = require("./DataEnumTypes/_instance")
local _number = require("./DataEnumTypes/_number")
local _string = require("./DataEnumTypes/_string")
local _u16 = require("./DataEnumTypes/_u16")
local _u32 = require("./DataEnumTypes/_u32")
local _udim = require("./DataEnumTypes/_udim")
local _udim2 = require("./DataEnumTypes/_udim2")
local _vector2 = require("./DataEnumTypes/_vector2")
local _vector2int16 = require("./DataEnumTypes/_vector2int16")
local _vector3 = require("./DataEnumTypes/_vector3")
local _vector3int16 = require("./DataEnumTypes/_vector3int16")
--[[
    Modules have _ prefix to not have it be typed by intellisense
]]

local DataTypes = {
    any = _any,

    -- primitives
    number = _number,
    string = _string,
    bool = _bool,

    -- numeric variants
    f32 = _f32,
    f64 = _f64,
    i8 = _i8,
    i16 = _i16,
    i32 = _i32,
    u16 = _u16,
    u32 = _u32,

    -- spatial
    vector2 = _vector2,
    vector3 = _vector3,
    vector2int16 = _vector2int16,
    vector3int16 = _vector3int16,
    cframe = _cframe,

    -- UI & visuals
    udim = _udim,
    udim2 = _udim2,

    -- misc
    --table = table,
    instance = _instance,
}

export type DataTypes = keyof<typeof(DataTypes)>

return DataTypes