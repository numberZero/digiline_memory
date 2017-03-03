-- © 2017 numberZero

local chip_size = digiline_memory.RAM_CHIP_SIZE
local bank_size = 16 * chip_size
local bank_positions = { 2, 5, 9, 12 }
local ram_layouts = {
	[1] = { false, true, false, false },
	[2] = { false, true, true, false },
	[4] = { true, true, true, true },
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

for bank_count, layout in pairs(ram_layouts) do
	local row_count = bank_size * bank_count
	local nodename = "digiline_memory:banked_ram_module_"..bank_count
	local desc = {
		label = string.format("RAM module (banked, %d rows)", row_count),
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
	for i = 1, 4 do
		local x = bank_positions[i]
		local y = layout[i] and 6 or -5
		local z = layout[i] and 7 or -6
		nodeboxes[#nodeboxes + 1] = {
			(x - 8) / 16,
			-6 / 16,
			-z / 16,
			(x - 6) / 16,
			y / 16,
			z / 16,
		}
	end
	minetest.register_node(nodename, {
		description = string.format("Digiline %d-bank RAM module (%d rows)", bank_count, row_count),
		drawtype = "nodebox",
		tiles = {
			string.format("digiline_memory_banked_ram_base.png^digiline_memory_banked_ram_%d.png", bank_count),
			"digiline_memory_flat.png",
			"digiline_memory_ram_bank.png^digiline_memory_banked_ram_side.png",
			"digiline_memory_ram_bank.png^digiline_memory_banked_ram_side.png",
			"digiline_memory_banked_ram_side2.png^digiline_memory_banked_ram_side.png",
			"digiline_memory_banked_ram_side2.png^digiline_memory_banked_ram_side.png",
		},
		paramtype = "light",
		groups = { dig_immediate = 2 },
		selection_box = {
			type = "fixed",
			fixed = {{ -8/16, -8/16, -8/16, 8/16, 6/16, 8/16 }}
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

minetest.register_craftitem("digiline_memory:ram_chip_set", {
	description = "8 digiline RAM chips",
	inventory_image = "digiline_memory_ram_chip_set.png",
})

minetest.register_craftitem("digiline_memory:banked_ram_module_base", {
	description = "Digiline banked RAM module base",
	inventory_image = "digiline_memory_banked_ram_base.png",
})

minetest.register_craftitem("digiline_memory:ram_bank_base", {
	description = "Digiline RAM bank base",
	inventory_image = "digiline_memory_ram_bank_base.png",
})

minetest.register_craftitem("digiline_memory:ram_bank", {
	description = "Digiline RAM bank",
	inventory_image = "digiline_memory_ram_bank.png",
})

-- Item crafting

minetest.register_craft({
	type = "shapeless",
	output = "digiline_memory:ram_chip_set",
	recipe = {
		"digiline_memory:ram_chip",
		"digiline_memory:ram_chip",
		"digiline_memory:ram_chip",
		"digiline_memory:ram_chip",
		"digiline_memory:ram_chip",
		"digiline_memory:ram_chip",
		"digiline_memory:ram_chip",
		"digiline_memory:ram_chip",
	},
})

minetest.register_craft({
	output = "digiline_memory:banked_ram_module_base 4",
	recipe = {
		{ "default:gold_ingot", "digilines:wire_std_00000000", "default:steel_ingot" },
		{ "digilines:wire_std_00000000", "default:glass", "digilines:wire_std_00000000" },
		{ "default:steel_ingot", "digilines:wire_std_00000000", "default:gold_ingot" },
	},
})

minetest.register_craft({
	output = "digiline_memory:banked_ram_module_base 4",
	recipe = {
		{ "default:steel_ingot", "digilines:wire_std_00000000", "default:gold_ingot" },
		{ "digilines:wire_std_00000000", "default:glass", "digilines:wire_std_00000000" },
		{ "default:gold_ingot", "digilines:wire_std_00000000", "default:steel_ingot" },
	},
})

minetest.register_craft({
	output = "digiline_memory:ram_bank_base 2",
	recipe = {
		{ "", "default:gold_ingot", "" },
		{ "default:copper_ingot", "default:glass", "default:copper_ingot" },
		{ "", "default:gold_ingot", "" },
	},
})

minetest.register_craft({
	output = "digiline_memory:ram_bank",
	recipe = {
--		{ "", "default:steel_ingot", "" },
		{ "digiline_memory:ram_chip_set", "digiline_memory:ram_bank_base", "digiline_memory:ram_chip_set" },
		{ "", "default:mese_crystal_fragment", "" },
	},
})

-- Module crafting

minetest.register_craft({
	type = "shapeless",
	output = "digiline_memory:banked_ram_module_1",
	recipe = {
		"digiline_memory:banked_ram_module_base",
		"digiline_memory:ram_bank",
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "digiline_memory:banked_ram_module_2",
	recipe = {
		"digiline_memory:banked_ram_module_base",
		"digiline_memory:ram_bank",
		"digiline_memory:ram_bank",
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "digiline_memory:banked_ram_module_4",
	recipe = {
		"digiline_memory:banked_ram_module_base",
		"digiline_memory:ram_bank",
		"digiline_memory:ram_bank",
		"digiline_memory:ram_bank",
		"digiline_memory:ram_bank",
	},
})

-- Module upgrading

minetest.register_craft({
	type = "shapeless",
	output = "digiline_memory:banked_ram_module_2",
	recipe = {
		"digiline_memory:banked_ram_module_1",
		"digiline_memory:ram_bank",
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "digiline_memory:banked_ram_module_4",
	recipe = {
		"digiline_memory:banked_ram_module_1",
		"digiline_memory:ram_bank",
		"digiline_memory:ram_bank",
		"digiline_memory:ram_bank",
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "digiline_memory:banked_ram_module_4",
	recipe = {
		"digiline_memory:banked_ram_module_2",
		"digiline_memory:ram_bank",
		"digiline_memory:ram_bank",
	},
})

-- Disassembling

minetest.register_craft({
	type = "shapeless",
	output = "digiline_memory:ram_chip 8",
	recipe = {
		"digiline_memory:ram_chip_set",
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "digiline_memory:ram_bank",
	recipe = {
		"digiline_memory:banked_ram_module_1",
	},
	replacements = {
		{"digiline_memory:banked_ram_module_1", "digiline_memory:banked_ram_module_base"},
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "digiline_memory:ram_bank 2",
	recipe = {
		"digiline_memory:banked_ram_module_2",
	},
	replacements = {
		{"digiline_memory:banked_ram_module_2", "digiline_memory:banked_ram_module_base"},
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "digiline_memory:ram_bank 4",
	recipe = {
		"digiline_memory:banked_ram_module_4",
	},
	replacements = {
		{"digiline_memory:banked_ram_module_4", "digiline_memory:banked_ram_module_base"},
	},
})

-- Aliases

minetest.register_alias("digiline_memory:memory_256", "digiline_memory:banked_ram_module_1")
minetest.register_alias("digiline_memory:memory_512", "digiline_memory:banked_ram_module_2")
minetest.register_alias("digiline_memory:memory_1024", "digiline_memory:banked_ram_module_4")
