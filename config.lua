Config = Config or {}

local whitelist = {
     models = {
          -- if a vehicle model exist in models script will skip class check!
          -- 'fiat600',
          'sjcop1'
     },
     classes = {
          -- https://docs.fivem.net/natives/?_0x29439776AAA00A62
          18 -- emergency
     }
}

Config.gunrack = {
     keybind = 'j',
     install_duration = 3, --sec
     opening_duration = 3, --sec
     while_open_animation = true, -- while inventory screen is on
     slots = 5,
     size = 50000,
     whitelist = whitelist
}
