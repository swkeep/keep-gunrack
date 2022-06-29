local Translations = {
     error = {
          dont_have_a_gunrack = "This vehicle doesn't have a gun rack!",
          not_authorized = 'You are not authorized!',
          already_installed = 'This vehicle already has a gun rack!',
          failed_to_use_gunrack = 'This vehicle already has a gun rack!',
          vehicle_is_not_allowed = 'This vehicle is not allowed to have a gun rack!',
          failed_to_read_plate = 'Failed to read plate!',
          must_be_in_vehicle = 'You must be in a vehicle!'
     },
     success = {
          successful_installation = 'Gunrack installation was successful'
     },
     info = {},
     progressbar = {
          installing_gun_rack = 'Installing Gun Rack',
          opening_gun_rack = 'Opening Gun Rack'
     },
     menu = {
          open = "Open Gun Rack"
     }
}

Lang = Locale:new({
     phrases = Translations,
     warnOnMissing = true
})
