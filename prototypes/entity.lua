require("prototypes.animations")
--require("circuit-connector-sprites")

local function blank()
  return {
    filename = "__modular_storage__/graphics/nothing.png",
    priority = "high",
    width = 1,
    height = 1,
  }
end
local function ablank()
  return {
    filename = "__modular_storage__/graphics/entity/empty.png",
    priority = "high",
    width = 1,
    height = 1,
    frame_count = 1,
  }
end

data:extend({
  {
    type = "electric-energy-interface",
    name = "controller",
    icon = "__modular_storage__/graphics/icons/controller.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation","not-blueprintable"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "controller"},
    max_health = 200,
    corpse = "small-remnants",
    collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      input_flow_limit = "60MW",
      output_flow_limit = "0MW",
      buffer_capacity = "1MJ",
    },
    energy_production = "0W",
    energy_usage = "0kW",
    animation =
    {
      layers =
      {
        {
          filename = "__modular_storage__/graphics/entity/controller/controller.png",
          priority = "extra-high",
          width = 34,
          height = 38,
          frame_count = 7,
          shift = util.by_pixel(0, -2),
          hr_version =
          {
            filename = "__modular_storage__/graphics/entity/controller/hr-controller.png",
            priority = "extra-high",
            width = 66,
            height = 74,
            frame_count = 7,
            shift = util.by_pixel(0, -2),
            scale = 0.5
          }
        },
        {
          filename = "__modular_storage__/graphics/entity/controller/controller-shadow.png",
          priority = "extra-high",
          width = 48,
          height = 24,
          repeat_count = 7,
          shift = util.by_pixel(8.5, 5.5),
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__modular_storage__/graphics/entity/controller/hr-controller-shadow.png",
            priority = "extra-high",
            width = 96,
            height = 44,
            repeat_count = 7,
            shift = util.by_pixel(8.5, 5),
            draw_as_shadow = true,
            scale = 0.5
          }
        }
      }
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    map_color = {r = 0.55, g = 0.55, b = 0.55},
    order="a-b-c",
    subgroup = "modularStorage"
  },
  {
    type = "storage-tank",
    name = "stockpileTile",
    icon = "__modular_storage__/graphics/icons/stockpile.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 2, result = "stockpileTile"},
    max_health = 200,
    corpse = "small-remnants",
    collision_box = {{-0.45, -0.45}, {0.45, 0.45}},--{{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    pictures = {
      picture =
      {
        sheet = {
          filename = "__modular_storage__/graphics/entity/stockpile.png",
          frames = 1,
          --priority = "extra-high",
          width = 48,
          height = 34,
          shift = {0.1875, 0},
        },
      },
        fluid_background = blank(),
        window_background = blank(),
        flow_sprite = blank(),
        gas_flow = ablank(),
    },
    window_bounding_box = {{0,0},{0,0}},
    fluid_box = {
      base_area = 1,
      pipe_covers = pipecoverspictures(),
      pipe_connections = {},
    },
    flow_length_in_ticks = 1,
    circuit_wire_connection_points = circuit_connector_definitions["storage-tank"].points,
    circuit_connector_sprites = circuit_connector_definitions["storage-tank"].sprites,
    circuit_wire_max_distance = 0,
    map_color = {r = 0.55, g = 0.55, b = 0.55},
    order="a-b-c",
    subgroup = "modularStorage"
  },
  {
    type = "transport-belt",
    name = "output",
    icon = "__modular_storage__/graphics/icons/output.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.3, result = "output"},
    max_health = 50,
    corpse = "small-remnants",
    resistances = 
    {
      {
        type = "fire",
        percent = 50
      }
    },
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/express-transport-belt.ogg",
        volume = 0.4
      },
      persistent = true
    },
    animation_speed_coefficient = 32,
    belt_animation_set = output_animation_set,    
    speed = 0.09375,
    connector_frame_sprites = transport_belt_connector_frame_sprites,
    circuit_wire_connection_points = circuit_connector_definitions["belt"].points,
    circuit_connector_sprites = circuit_connector_definitions["belt"].sprites,
    circuit_wire_max_distance = transport_belt_circuit_wire_max_distance,
    order="a-b-c",
    subgroup = "modularStorage"
  }, 
  {
    type = "transport-belt",
    name = "input",
    icon = "__modular_storage__/graphics/icons/input.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.1, result = "input"},
    max_health = 50,
    corpse = "small-remnants",
    resistances = 
    {
      {
        type = "fire",
        percent = 50
      }
    },
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/express-transport-belt.ogg",
        volume = 0.4
      },
      persistent = true
    },
    animation_speed_coefficient = 32,
    belt_animation_set = input_animation_set,
    speed = 0.09375,
    connector_frame_sprites = transport_belt_connector_frame_sprites,
    circuit_wire_connection_points = circuit_connector_definitions["belt"].points,
    circuit_connector_sprites = circuit_connector_definitions["belt"].sprites,
    circuit_wire_max_distance = transport_belt_circuit_wire_max_distance,
    order="a-b-c",
    subgroup = "modularStorage"
  },
  {
    type = "container",
    name = "interface",
    icon = "__modular_storage__/graphics/icons/interface.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "interface"},
    max_health = 200,
    corpse = "small-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    resistances =
    {
      {
        type = "fire",
        percent = 80
      },
      {
        type = "impact",
        percent = 30
      }
    },
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    inventory_size = 32,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    picture =
    {
      filename = "__modular_storage__/graphics/entity/interface.png",
      priority = "extra-high",
      width = 48,
      height = 34,
      shift = {0.1875, 0}
    },
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {0.734375, 0.453125},
        green = {0.609375, 0.515625},
      },
      wire =
      {
        red = {0.40625, 0.21875},
        green = {0.40625, 0.375},
      }
    },
    circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
    circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
    circuit_wire_max_distance = 9,
    order="a-b-c",
    subgroup = "modularStorage"
  },
  {
    type = "constant-combinator",
    name = "inventory-panel",
    icon = "__modular_storage__/graphics/icons/inventory-panel.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "inventory-panel"},
    max_health = 50,
    corpse = "small-remnants",
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    item_slot_count = 1000,
    sprites =
    {
      north =
      {
        filename = "__modular_storage__/graphics/entity/inventory-panel.png",
        x = 158,
        y = 5,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
      },
      east =
      {
        filename = "__modular_storage__/graphics/entity/inventory-panel.png",
        y = 5,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
      },
      south =
      {
        filename = "__modular_storage__/graphics/entity/inventory-panel.png",
        x = 237,
        y = 5,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
      },
      west =
      {
        filename = "__modular_storage__/graphics/entity/inventory-panel.png",
        x = 79,
        y = 5,
        width = 79,
        height = 63,
        frame_count = 1,
        shift = {0.140625, 0.140625},
      }
    },

    activity_led_sprites =
    {
      north =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png",
        width = 8,
        height = 6,
        frame_count = 1,
        shift = util.by_pixel(9, -12),
        hr_version =
        {
          scale = 0.5,
          filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-N.png",
          width = 14,
          height = 12,
          frame_count = 1,
          shift = util.by_pixel(9, -11.5),
        },
      },
      east =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-E.png",
        width = 8,
        height = 8,
        frame_count = 1,
        shift = util.by_pixel(8, 0),
        hr_version =
        {
          scale = 0.5,
          filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-E.png",
          width = 14,
          height = 14,
          frame_count = 1,
          shift = util.by_pixel(7.5, -0.5),
        },
      },
      south =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-S.png",
        width = 8,
        height = 8,
        frame_count = 1,
        shift = util.by_pixel(-9, 2),
        hr_version =
        {
          scale = 0.5,
          filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-S.png",
          width = 14,
          height = 16,
          frame_count = 1,
          shift = util.by_pixel(-9, 2.5),
        },
      },
      west =
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-W.png",
        width = 8,
        height = 8,
        frame_count = 1,
        shift = util.by_pixel(-7, -15),
        hr_version =
        {
          scale = 0.5,
          filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-W.png",
          width = 14,
          height = 16,
          frame_count = 1,
          shift = util.by_pixel(-7, -15),
        },
      },
    },

    activity_led_light =
    {
      intensity = 0.8,
      size = 1,
    },

    activity_led_light_offsets =
    {
      {0.296875, -0.40625},
      {0.25, -0.03125},
      {-0.296875, -0.078125},
      {-0.21875, -0.46875}
    },

    circuit_wire_connection_points =
    {
      {
        shadow =
        {
          red = {0.15625, -0.28125},
          green = {0.65625, -0.25}
        },
        wire =
        {
          red = {-0.28125, -0.5625},
          green = {0.21875, -0.5625},
        }
      },
      {
        shadow =
        {
          red = {0.75, -0.15625},
          green = {0.75, 0.25},
        },
        wire =
        {
          red = {0.46875, -0.5},
          green = {0.46875, -0.09375},
        }
      },
      {
        shadow =
        {
          red = {0.75, 0.5625},
          green = {0.21875, 0.5625}
        },
        wire =
        {
          red = {0.28125, 0.15625},
          green = {-0.21875, 0.15625}
        }
      },
      {
        shadow =
        {
          red = {-0.03125, 0.28125},
          green = {-0.03125, -0.125},
        },
        wire =
        {
          red = {-0.46875, 0},
          green = {-0.46875, -0.40625},
        }
      }
    },

    circuit_wire_max_distance = 7.5
  }
})
