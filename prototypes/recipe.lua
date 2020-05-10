data:extend({
  {
    type = "recipe",
    name = "modular-storage-controller",
    enabled = false,
    energy_required = 10,
    ingredients = 
    {      
      {"substation",5},
      {"steel-plate",100},
      {"processing-unit",15},
    },
    result = "modular-storage-controller"
  },
  {
    type = "recipe",
    name = "modular-storage-stockpileTile",
    enabled = false,
    energy_required = 0.5,
    ingredients = 
    {
      {"steel-chest",1},
      {"processing-unit",5},
    },
    result = "modular-storage-stockpileTile"
  },
  {
    type = "recipe",
    name = "modular-storage-output",
    enabled = false,
    energy_required = 5,
    ingredients = {
      {"express-transport-belt",4},
      {"processing-unit",5},
      {"iron-gear-wheel",20},
    },
    result = "modular-storage-output"
  },
  {
    type = "recipe",
    name = "modular-storage-input",
    enabled = false,
    energy_required = 5,
    ingredients = {
      {"express-transport-belt",4},
      {"processing-unit",5},
      {"iron-gear-wheel",20},
    },
    result = "modular-storage-input"
  },
  {
    type = "recipe",
    name = "modular-storage-interface",
    enabled = false,
    energy_required = 5,
    ingredients = {
      {"steel-chest",1},
      {"processing-unit",10},
      {"iron-gear-wheel",30},
    },
    result = "modular-storage-interface"
  },
  {
    type = "recipe",
    name = "modular-storage-inventory-panel",
    enabled = false,
    energy_required = 5,
    ingredients =
    {
      {"constant-combinator", 1},
      {"copper-cable", 10},
      {"processing-unit", 5}
    },
    result = "modular-storage-inventory-panel"
  }
})
