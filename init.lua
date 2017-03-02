-- © 2017 numberZero
-- Input format: {cmd=<string>, addr=<integer>, value=<anything>}
-- Output format: {ok=<bool>, value=<anything>}
-- Commands: get, set, clear
-- Addresses are zero-based integers

local MODPATH = minetest.get_modpath("digiline_memory")

digiline_memory = {}

dofile(MODPATH.."/memory.lua")
dofile(MODPATH.."/ram.lua")
