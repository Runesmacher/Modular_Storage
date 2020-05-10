data:extend({
	-- Global
	{
		type = "int-setting",
		name = "modular-storage-base-power",
		setting_type = "runtime-global",
		default_value = 40000,
		minimum_value = 0,
		order = "a",
	},
	{
		type = "int-setting",
		name = "modular-storage-power-per-tile",
		setting_type = "runtime-global",
		default_value = 100,
		minimum_value = 0,
		order = "b",
	},
	{
		type = "int-setting",
		name = "modular-storage-power-per-InOut",
		setting_type = "runtime-global",
		default_value = 5000,
		minimum_value = 0,
		order = "b",
	},
	{
		type = "int-setting",
		name = "modular-storage-power-per-interface",
		setting_type = "runtime-global",
		default_value = 1000,
		minimum_value = 0,
		order = "b",
	},
	{
		type = "int-setting",
		name = "modular-storage-items-per-tile",
		setting_type = "runtime-global",
		default_value = 2000,
		minimum_value = 1,
		order = "c",
	},
	{
		type = "int-setting",
		name = "modular-storage-circuit-update-rate",
		setting_type = "runtime-global",
		default_value = 30,
		minimum_value = 1,
		order = "c",
	}
})
