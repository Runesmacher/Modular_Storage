data:extend({
  {
    type = "technology",
    name = "stockpile-tech",
    icon = "__modular_storage__/graphics/icon.png",
    icon_size = 32,
    effects = {
      {
        type = "unlock-recipe",
        recipe = "controller"
      },
      {
        type = "unlock-recipe",
        recipe = "stockpileTile"
      },
      {
        type = "unlock-recipe",
        recipe = "output"
      },
      {
        type = "unlock-recipe",
        recipe = "input"
      },
      {
        type = "unlock-recipe",
        recipe = "interface"
      },
      {
        type = "unlock-recipe",
        recipe = "inventory-panel"
      },
    },
    prerequisites = {
      "logistics-3",
      "advanced-electronics-2"
    },
    unit = {
      count = 400,
      ingredients = {
        {"automation-science-pack", 2},
        {"logistic-science-pack", 2},
        {"production-science-pack", 1}
      },
      time = 30
    }
  }
})
