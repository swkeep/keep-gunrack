# keep-gunrack

Allows police to add and open gun racks.
Gun racks are hidden from other non-police players.

# Preview

[Video](https://youtu.be/7xqfX3gC_po)

# Dependencies

- qb-core
- progressbar
- qb-radialmenu

# How to Install

- step0: Add `images/policegunrack.png` to `qb-inventory/html/images`
- step1: Add Below code to `qb-core/shared/items.lua`

```lua
["policegunrack"] = {
     ["name"] = "policegunrack",
     ["label"] = "Police Gun Rack",
     ["weight"] = 15000,
     ["type"] = "item",
     ["image"] = "policegunrack.png",
     ["unique"] = false,
     ["useable"] = true,
     ["shouldClose"] = true,
     ["combinable"] = nil,
     ["description"] = "Gun rack for police vehicles"
},
```

- last step: ensure script after all dependencies `ensure keep-gunrack` (server.cfg)

# Config

- Add vehicle's models or classes you want to get whitelisted
- Customize rack size and durations

# Support

- https://discord.gg/ccMArCwrPV
