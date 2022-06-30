# keep-gunrack

Allows police to add and open gun racks.
Gun racks are hidden from other non-police players.

# Preview

[Video](https://youtu.be/7xqfX3gC_po)

# Keys

- To use keys you need to first cut them using cutting machine
- To do that you need a 'keycuttingmachine' and make sure your citizenid is whitelisted.
- Add a key (gunrackkey) to your inventory (script and will try to find an unused key).
- Type the vehicle's plate and you are done with key cutting.

- Using key by itself won't work it has to be in your inventory to let keybind or raidal menu to work.
- After deactivation of job check, the radial menu will be deactivated and you can only open gunracks with keybind.

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
-- optional if you want to open rack by keys
["gunrackkey"] = {
     ["name"] = "gunrackkey",
     ["label"] = "Police Gun Key",
     ["weight"] = 500,
     ["type"] = "item",
     ["image"] = "gunrackkey.png",
     ["unique"] = false,
     ["useable"] = true,
     ["shouldClose"] = true,
     ["combinable"] = nil,
     ["description"] = "A key to open gun rack"
},
["keycuttingmachine"] = {
     ["name"] = "keycuttingmachine",
     ["label"] = "Key Cutting Machine",
     ["weight"] = 40000,
     ["type"] = "item",
     ["image"] = "keycuttingmachine.png",
     ["unique"] = false,
     ["useable"] = true,
     ["shouldClose"] = true,
     ["combinable"] = nil,
     ["description"] = "A Machine to Cut Keys"
},
```

- last step: ensure script after all dependencies `ensure keep-gunrack` (server.cfg)
- if you did install keys make sure you have right config setup example:

```lua
     disable_job_check = true, -- <--- this value will disable job check
     use_keys_to_unlock_gunrack = true,
```

# Config

- Add vehicle's models or classes you want to get whitelisted
- Customize rack size and durations

# Support

- https://discord.gg/ccMArCwrPV
