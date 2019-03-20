data:extend({
	-- Global
	{
		type = "int-setting",
		name = "mudular-storage-base-power",
		setting_type = "runtime-global",
		default_value = 40000,
		minimum_value = 0,
		order = "a-a",
	},
	{
		type = "int-setting",
		name = "mudular-storage-stockpile-power",
		setting_type = "runtime-global",
		default_value = 1000,
		minimum_value = 0,
		order = "a-b",
	},
	{
		type = "int-setting",
		name = "mudular-storage-items-per-tile",
		setting_type = "runtime-global",
		default_value = 2000,
		minimum_value = 1,
		order = "a-b",
	},
	{
		type = "int-setting",
		name = "mudular-storage-circuit-update-rate",
		setting_type = "runtime-global",
		default_value = 30,
		minimum_value = 1,
		order = "a-b",
	},
	{
		type = "int-setting",
		name = "mudular-storage-interface-update-rate",
		setting_type = "runtime-global",
		default_value = 30,
		minimum_value = 1,
		order = "a-b",
	}
})
