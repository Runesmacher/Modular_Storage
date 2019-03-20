data:extend({
  {
    type = "recipe",
    name = "controller",
    enabled = "false",
    ingredients = 
    {      
      {"substation",5},
      {"steel-plate",100},
      {"processing-unit",15},
    },
    result = "controller"
  },
  {
    type = "recipe",
    name = "stockpileTile",
    enabled = "false",
    ingredients = 
    {
      {"steel-chest",1},
      {"processing-unit",5},
    },
    result = "stockpileTile"
  },
  {
    type = "recipe",
    name = "output",
    enabled = false,
    ingredients = {
      {"express-transport-belt",4},
      {"processing-unit",5},
      {"iron-gear-wheel",20},
    },
    result = "output"
  },
  {
    type = "recipe",
    name = "input",
    enabled = false,
    ingredients = {
      {"express-transport-belt",4},
      {"processing-unit",5},
      {"iron-gear-wheel",20},
    },
    result = "input"
  },
  {
    type = "recipe",
    name = "interface",
    enabled = false,
    ingredients = {
      {"steel-chest",1},
      {"processing-unit",10},
      {"iron-gear-wheel",30},
    },
    result = "interface"
  },
  {
    type = "recipe",
    name = "inventory-panel",
    enabled = false,
    ingredients =
    {
      {"constant-combinator", 1},
      {"copper-cable", 10},
      {"processing-unit", 5}
    },
    result = "inventory-panel"
  }
})
