data:extend({
    {
      type = "item-subgroup",
      name = "modularStorage",
      group = "logistics",
      order = "z"
    },
  {
    type= "item",
		name= "modular-storage-controller",
		icon = "__modular_storage__/graphics/icons/controller.png",
    icon_size = 32,
		subgroup = "modularStorage",
		order = "a",
		place_result = "modular-storage-controller",
		stack_size = 50
	},
  {
    type= "item",
		name= "modular-storage-stockpileTile",
		icon = "__modular_storage__/graphics/icons/stockpile.png",
    icon_size = 32,
		subgroup = "modularStorage",
		order = "b",
		place_result = "modular-storage-stockpileTile",
		stack_size = 50
	},
	{
    type = "item",
    name = "modular-storage-input",
    icon = "__modular_storage__/graphics/icons/input.png",
    icon_size = 32,
    subgroup = "modularStorage",
    order = "c",
    place_result = "modular-storage-input",
    stack_size = 50
	},
  {
    type = "item",
    name = "modular-storage-output",
    icon = "__modular_storage__/graphics/icons/output.png",
    icon_size = 32,
    subgroup = "modularStorage",
    order = "c",
    place_result = "modular-storage-output",
    stack_size = 50
  },
	{
    type = "item",
    name = "modular-storage-interface",
    icon = "__modular_storage__/graphics/icons/interface.png",
    icon_size = 32,
    subgroup = "modularStorage",
    order = "d",
    place_result = "modular-storage-interface",
    stack_size = 50
	},
  {
    type = "item",
    name = "modular-storage-inventory-panel",
    icon = "__modular_storage__/graphics/icons/inventory-panel.png",
    icon_size = 32,
    subgroup = "modularStorage",
    order = "e",
    place_result="modular-storage-inventory-panel",
    stack_size= 50,
  }
})
