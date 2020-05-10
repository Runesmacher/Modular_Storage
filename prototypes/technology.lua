data:extend({
  {
    type = "technology",
    name = "modular-storage-stockpile-tech",
    icon = "__modular_storage__/graphics/icon.png",
    icon_size = 32,
    effects = {
      {
        type = "unlock-recipe",
        recipe = "modular-storage-controller"
      },
      {
        type = "unlock-recipe",
        recipe = "modular-storage-stockpileTile"
      },
      {
        type = "unlock-recipe",
        recipe = "modular-storage-output"
      },
      {
        type = "unlock-recipe",
        recipe = "modular-storage-input"
      },
      {
        type = "unlock-recipe",
        recipe = "modular-storage-interface"
      },
      {
        type = "unlock-recipe",
        recipe = "modular-storage-inventory-panel"
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
