--                _
--               | |
--   _____      _| | _____  ___ _ __
--  / __\ \ /\ / / |/ / _ \/ _ \ '_ \
--  \__ \\ V  V /|   <  __/  __/ |_) |
--  |___/ \_/\_/ |_|\_\___|\___| .__/
--                             | |
--                             |_|
-- https://github.com/swkeep
local QBCore = exports['qb-core']:GetCoreObject()

-- functions

local function remove_item(src, Player, name, amount)
     local res = Player.Functions.RemoveItem(name, amount)
     TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[name], "remove")
     return res
end

local function isAlreadyInstalled(plate)
     local stash = 'Gunrack_' .. plate
     local result = MySQL.Sync.fetchScalar("SELECT EXISTS(SELECT id FROM stashitems WHERE stash= ?)", { stash })
     if result == 1 then return true else return false end
end

-- callbacks

QBCore.Functions.CreateUseableItem('policegunrack', function(source, item)
     local Player = QBCore.Functions.GetPlayer(source)
     if not Player then return end
     if not Player.PlayerData.job.name == 'police' then
          TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_authorized'), "error")
          return
     end
     TriggerClientEvent('keep-gunrack:client:start_installing_gunrack', source)
end)

-- events

RegisterNetEvent('keep-gunrack:server:create_gunrack', function(plate)
     local src = source
     local Player = QBCore.Functions.GetPlayer(src)

     if not Player.PlayerData.job.name == 'police' then
          TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_authorized'), "error")
          return
     end

     if isAlreadyInstalled(plate) then
          TriggerClientEvent('QBCore:Notify', src, Lang:t('error.already_installed'), "error")
          return
     end

     if not remove_item(src, Player, 'policegunrack', 1) then
          TriggerClientEvent('QBCore:Notify', src, Lang:t('error.failed_to_use_gunrack'), "error")
          return
     end

     TriggerClientEvent('QBCore:Notify', src, Lang:t('success.successful_installation'), "success")
     TriggerClientEvent('keep-gunrack:client:open_gunrack', src, plate)
end)

RegisterNetEvent('keep-gunrack:server:open_gunrack_by_menu', function(plate)
     local src = source
     local Player = QBCore.Functions.GetPlayer(src)
     if not Player then return end
     if not Player.PlayerData.job.name == 'police' then
          TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_authorized'), "error")
          return
     end

     if isAlreadyInstalled(plate) then
          TriggerClientEvent('keep-gunrack:client:open_gunrack', src, plate)
          return
     else
          TriggerClientEvent('QBCore:Notify', src, Lang:t('error.dont_have_a_gunrack'), "error")
          return
     end
end)
