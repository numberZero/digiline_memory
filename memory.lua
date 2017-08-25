-- © 2017 numberZero

local ROW_SIZE_LIMIT = 4 * 1024
local MSG_INVALID_ADDRESS = "Invalid address"
local MSG_DATA_TOO_LONG = "Data too long"

local function get_meta_field_name(addr, desc)
	if type(addr) ~= "number" then
		return false
	end
	local int, frac = math.modf(addr)
	if frac ~= 0 or int < 0 or int >= desc.size then
		return false
	end
	return true, "data_"..int
end

function digiline_memory.on_digiline_receive(pos, node, channel, msg)
	if type(msg) ~= "table" or not msg.cmd then
		return
	end
	local meta = minetest.get_meta(pos)
	if channel ~= meta:get_string("channel") then
		return
	end
	local ok = false
	local addr
	local value
	local desc = minetest.registered_nodes[minetest.get_node(pos).name].digiline_memory
	if msg.cmd == "get" then
		ok, addr = get_meta_field_name(msg.addr, desc)
		if ok then
			value = minetest.deserialize(meta:get_string(addr))
		else
			value = MSG_INVALID_ADDRESS
		end
	elseif msg.cmd == "set" then
		ok, addr = get_meta_field_name(msg.addr, desc)
		if ok then
			if msg.value == nil then
				value = ""
			else
				value = minetest.serialize(msg.value)
			end
			if #value > ROW_SIZE_LIMIT then
				ok = false
				value = MSG_DATA_TOO_LONG
			else
				meta:set_string(addr, value)
				meta:mark_as_private(addr)
				value = nil -- don't send it back
			end
		else
			value = MSG_INVALID_ADDRESS
		end
	elseif msg.cmd == "clear" then
		if desc.reset then
			ok = desc:reset(pos) ~= false
		end
	end
	digiline:receptor_send(pos, digiline.rules.default, channel, {ok=ok, value=value})
end
