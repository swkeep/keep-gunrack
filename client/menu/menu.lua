Menu = { id = nil }

--  class
function Menu:create()
     if self.id ~= nil then return end
     self.id = exports['qb-radialmenu']:AddOption({
          id = 'keep_gunrack_',
          title = Lang:t('menu.open'),
          icon = 'car',
          type = 'client',
          event = 'keep-gunrack:client:open_gunrack_menu',
          shouldClose = true
     })
end

function Menu:destroy()
     if self.id then
          exports['qb-radialmenu']:RemoveOption(self.id)
          self.id = nil
     end
end

RegisterKeyMapping('+openGunRack', 'open gun rack', 'keyboard', Config.gunrack.keybind)
RegisterCommand('+openGunRack', function()
     local allowed = IsJobAllowed(PlayerJob.name)
     if not IsPauseMenuActive() and allowed then
          TriggerEvent('keep-gunrack:client:open_gunrack_menu')
     elseif not IsPauseMenuActive() and not (allowed) then
          TriggerEvent('QBCore:Notify', Lang:t('error.not_authorized'), "error")
     end
end, false)

RegisterNetEvent('keep-gunrack:menu:open_rack_by_key', function()
     local allowed = IsJobAllowed(PlayerJob.name)
     if not IsPauseMenuActive() and allowed then
          TriggerEvent('keep-gunrack:client:open_gunrack_menu')
     elseif not IsPauseMenuActive() and not (allowed) then
          TriggerEvent('QBCore:Notify', Lang:t('error.not_authorized'), "error")
     end
end)
