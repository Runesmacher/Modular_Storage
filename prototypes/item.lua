data:extend({
    {
      type = "item-subgroup",
      name = "modularStorage",
      group = "logistics",
      order = "z"
    },
  {
    type= "item",
		name= "controller",
		icon = "__modular_storage__/graphics/icons/controller.png",
    icon_size = 32,
		subgroup = "modularStorage",
		order = "a-b-c",
		place_result = "controller",
		stack_size = 50
	},
  {
    type= "item",
		name= "stockpileTile",
		icon = "__modular_storage__/graphics/icons/stockpile.png",
    icon_size = 32,
		subgroup = "modularStorage",
		order = "a-b-c",
		place_result = "stockpileTile",
		stack_size = 50
	},
  {
    type = "item",
    name = "output",
    icon = "__modular_storage__/graphics/icons/output.png",
    icon_size = 32,
    subgroup = "modularStorage",
    order = "c[output]",
    place_result = "output",
    stack_size = 50
  },
	{
    type = "item",
    name = "input",
    icon = "__modular_storage__/graphics/icons/input.png",
    icon_size = 32,
    subgroup = "modularStorage",
    order = "c[input]",
    place_result = "input",
    stack_size = 50
	},
	{
    type = "item",
    name = "interface",
    icon = "__modular_storage__/graphics/icons/interface.png",
    icon_size = 32,
    subgroup = "modularStorage",
    order = "c[interface]",
    place_result = "interface",
    stack_size = 50
	},
  {
    type = "item",
    name = "inventory-panel",
    icon = "__modular_storage__/graphics/icons/inventory-panel.png",
    icon_size = 32,
    subgroup = "modularStorage",
    order = "c[inventory-panel]",
    place_result="inventory-panel",
    stack_size= 50,
  }
})
