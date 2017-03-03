-- © 2017 numberZero

local chip_size = digiline_memory.RAM_CHIP_SIZE
local ram_layouts = {
	[1] = {
		{x=6, y=7, w=4, h=2},
	},
	[2] = {
		{x=4, y=6, w=2, h=4},
		{x=10, y=6, w=2, h=4},
	},
	[4] = {
		{x=3, y=4, w=4, h=2},
		{x=3, y=10, w=4, h=2},
		{x=9, y=4, w=4, h=2},
		{x=9, y=10, w=4, h=2},
	},
	[8] = {
		{x=2, y=3, w=2, h=4},
		{x=5, y=3, w=2, h=4},
		{x=9, y=3, w=2, h=4},
		{x=12, y=3, w=2, h=4},
		{x=2, y=9, w=2, h=4},
		{x=5, y=9, w=2, h=4},
		{x=9, y=9, w=2, h=4},
		{x=12, y=9, w=2, h=4},
	},
}

local function reset(desc, pos)
	local meta = minetest.get_meta(pos)
	meta:from_table({
		inventory = {},
		fields = {
			formspec = "field[channel;Channel;${channel}]",
			infotext = desc.label,
			channel = "",
		}
	})
end

local function receive_fields(pos, formname, fields, sender)
	if fields.channel then
		local meta = minetest.get_meta(pos)
		meta:set_string("channel", fields.channel)
	end
end

for chip_count, layout in pairs(ram_layouts) do
	local row_count = chip_size * chip_count
	local nodename = "digiline_memory:ram_module_"..chip_count
	local desc = {
		label = string.format("RAM module (%d rows)", row_count),
		size = row_count,
		reset = reset,
	}
	local nodeboxes = {
		{ -8/16, -8/16, -8/16, 8/16, -7/16, 8/16 },
		{ -7/16, -7/16, -7/16, 7/16, -6/16, 7/16 },

		{ -8/16, -7/16, -2/16, -7/16, -6/16, 2/16 },
		{  8/16, -7/16, -2/16,  7/16, -6/16, 2/16 },
		{ -2/16, -7/16, -8/16,  2/16, -6/16, -7/16 },
		{ -2/16, -7/16,  8/16,  2/16, -6/16,  7/16 },
	}
	for _, chip in ipairs(layout) do
		nodeboxes[#nodeboxes + 1] = {
			(chip.x - 8) / 16,
			-6 / 16,
			(chip.y - 8) / 16,
			(chip.x + chip.w - 8) / 16,
			-5 / 16,
			(chip.y + chip.h - 8) / 16,
		}
	end
	minetest.register_node(nodename, {
		description = string.format("Digiline %d-chip RAM module (%d rows)", chip_count, row_count),
		drawtype = "nodebox",
		tiles = {
			string.format("digiline_memory_ram_base.png^digiline_memory_ram_%d.png", chip_count),
			"digiline_memory_flat.png",
			"digiline_memory_ram_side.png",
		},
		paramtype = "light",
		groups = { dig_immediate = 2 },
		selection_box = {
			type = "fixed",
			fixed = {{ -8/16, -8/16, -8/16, 8/16, -4/16, 8/16 }}
		},
		node_box = {
			type = "fixed",
			fixed = nodeboxes,
		},
		digiline = {
			receptor = {},
			effector = { action = digiline_memory.on_digiline_receive },
		},
		digiline_memory = desc,
		on_construct = function(pos) reset(desc, pos) end,
		on_receive_fields = receive_fields,
	})
end

-- Craftitems

minetest.register_craftitem("digiline_memory:ram_chip", {
	description = "Digiline RAM chip",
	inventory_image = "digiline_memory_ram_chip.png",
})

minetest.register_craftitem("digiline_memory:ram_module_base", {
	description = "Digiline RAM module base",
	inventory_image = "digiline_memory_ram_base.png",
})

-- Item crafting

minetest.register_craft({
	output = "digiline_memory:ram_module_base 4",
	recipe = {
		{ "default:copper_ingot", "digilines:wire_std_00000000", "default:steel_ingot" },
		{ "digilines:wire_std_00000000", "default:glass", "digilines:wire_std_00000000" },
		{ "default:steel_ingot", "digilines:wire_std_00000000", "default:copper_ingot" },
	},
})

minetest.register_craft({
	output = "digiline_memory:ram_module_base 4",
	recipe = {
		{ "default:steel_ingot", "digilines:wire_std_00000000", "default:copper_ingot" },
		{ "digilines:wire_std_00000000", "default:glass", "digilines:wire_std_00000000" },
		{ "default:copper_ingot", "digilines:wire_std_00000000", "default:steel_ingot" },
	},
})

minetest.register_craft({
	output = "digiline_memory:ram_chip 2",
	recipe = {
		{ "mesecons_materials:silicon", "default:mese_crystal_fragment", "mesecons_materials:silicon" },
		{ "mesecons_materials:silicon", "default:gold_ingot", "mesecons_materials:silicon" },
	},
})

-- Module crafting

minetest.register_craft({
	output = "digiline_memory:ram_module_1",
	recipe = {
		{ "digiline_memory:ram_chip" },
		{ "digiline_memory:ram_module_base" },
	},
})

minetest.register_craft({
	output = "digiline_memory:ram_module_2",
	recipe = {
		{ "digiline_memory:ram_chip" },
		{ "digiline_memory:ram_module_base" },
		{ "digiline_memory:ram_chip" },
	},
})

minetest.register_craft({
	output = "digiline_memory:ram_module_4",
	recipe = {
		{ "digiline_memory:ram_chip", "", "digiline_memory:ram_chip" },
		{ "", "digiline_memory:ram_module_base", "" },
		{ "digiline_memory:ram_chip", "", "digiline_memory:ram_chip" },
	},
})

minetest.register_craft({
	output = "digiline_memory:ram_module_8",
	recipe = {
		{ "digiline_memory:ram_chip", "digiline_memory:ram_chip", "digiline_memory:ram_chip" },
		{ "digiline_memory:ram_chip", "digiline_memory:ram_module_base", "digiline_memory:ram_chip" },
		{ "digiline_memory:ram_chip", "digiline_memory:ram_chip", "digiline_memory:ram_chip" },
	},
})

-- Aliases

minetest.register_alias("digiline_memory:memory_16", "digiline_memory:ram_module_1")
minetest.register_alias("digiline_memory:memory_32", "digiline_memory:ram_module_2")
minetest.register_alias("digiline_memory:memory_64", "digiline_memory:ram_module_4")
minetest.register_alias("digiline_memory:memory_128", "digiline_memory:ram_module_8")
