data:extend({
  {
    type = "item-subgroup",
    name = "stockpile-data",
    group = "signals",
    order = "x[stockpile-data]"
  },
  {
    type = "virtual-signal",
    name = "stocpile-space-left",
    icon = "__modular_storage__/graphics/icons/stocpile-space-left.png",
    icon_size = 32,
    subgroup = "stockpile-data",
    order = "x[stockpile-data]-ba"
  },
  {
    type = "virtual-signal",
    name = "stocpile-size",
    icon = "__modular_storage__/graphics/icons/stocpile-size.png",
    icon_size = 32,
    subgroup = "stockpile-data",
    order = "x[stockpile-data]-bb"
  }
})