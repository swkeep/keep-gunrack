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
     local stash = Config.gunrack.stash_prefix .. plate
     local result = MySQL.Sync.fetchScalar("SELECT EXISTS(SELECT id FROM stashitems WHERE stash= ?)", { stash })
     if result == 1 then return true else return false end
end

local function does_player_have_keys(Player, plate)
     local keys = Player.Functions.GetItemsByName('gunrackkey')
     if next(keys) == nil then return false end


     for _, item in ipairs(keys) do
          if item.info ~= nil or type(item.info) == "table" then
               if item.info.plate == plate then
                    return true
               end
          end
     end
     return false
end

-- callbacks

local function HasItem(source, Player, item_name)
     local item = Player.Functions.GetItemByName(item_name)
     if item then
          TriggerClientEvent('QBCore:Notify', source, "You don't have a Gun Rack?!", 'error')
          return true
     end
     return false
end

QBCore.Functions.CreateUseableItem('policegunrack', function(source, item)
     local Player = QBCore.Functions.GetPlayer(source)
     if not Player then return end
     if not IsJobAllowed(Player.PlayerData.job.name) then
          TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_authorized'), "error")
          return
     end

     TriggerClientEvent('keep-gunrack:client:start_installing_gunrack', source)
end)


if Config.gunrack.use_keys_to_unlock_gunrack then
     QBCore.Functions.CreateUseableItem('gunrackkey', function(source, item)
          TriggerClientEvent('keep-gunrack:menu:open_rack_by_key', source)
     end)

     local function IsPlayerWhitelisted(citizenid)
          for _, id in ipairs(Config.gunrack.whitelist.key_cutting_citizenid) do
               if citizenid == id then
                    return true
               end
          end
          return false
     end

     QBCore.Functions.CreateUseableItem('keycuttingmachine', function(source, item)
          local src = source
          local Player = QBCore.Functions.GetPlayer(src)
          if not Player then return end
          if not IsPlayerWhitelisted(Player.PlayerData.citizenid) then
               TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_authorized'), "error")
               return
          end
          TriggerClientEvent('keep-gunrack:client:cut_key', source)
     end)

     local function find_unused_keys(Player)
          local keys = Player.Functions.GetItemsByName('gunrackkey')
          if next(keys) == nil then return {} end
          local tmp = {}

          for _, item in ipairs(keys) do
               if item.info == nil or type(item.info) ~= "table" or
                   (type(item.info) == 'table' and (item.info['plate'] == nil or item.info['plate'] == '')) then
                    tmp[#tmp + 1] = item
               end
          end

          return tmp
     end

     local function get_one_unused_key(Player)
          local keys = find_unused_keys(Player)
          if next(keys) == nil then return end

          for _, key in ipairs(keys) do
               return key
          end
     end

     local function save_key_info(Player, item, plate)
          if Player.PlayerData.items[item.slot] then
               if not (type(Player.PlayerData.items[item.slot].info) == "table") then
                    Player.PlayerData.items[item.slot].info = {}
                    Player.PlayerData.items[item.slot].info.plate = plate
               else
                    Player.PlayerData.items[item.slot].info.plate = plate
               end
          end
          Player.Functions.SetInventory(Player.PlayerData.items, true)
     end

     RegisterNetEvent('keep-gunrack:server:start_cut_key', function(plate)
          local src = source
          local Player = QBCore.Functions.GetPlayer(src)

          if not IsPlayerWhitelisted(Player.PlayerData.citizenid) then
               TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_authorized'), "error")
               return
          end

          local key = Player.Functions.GetItemByName('gunrackkey')
          if not key then
               TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_key_found'), "error")
               return
          end

          TriggerClientEvent('keep-gunrack:client:keycuttingmachine_animation', src, plate)
     end)

     --
     RegisterNetEvent('keep-gunrack:server:cut_key', function(plate)
          local src = source
          local Player = QBCore.Functions.GetPlayer(src)

          if not IsPlayerWhitelisted(Player.PlayerData.citizenid) then
               TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_authorized'), "error")
               return
          end

          local key = get_one_unused_key(Player)
          if key == nil then
               TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_unused_keys_found'), "error")
               return
          end
          save_key_info(Player, key, plate)
          TriggerClientEvent('QBCore:Notify', src, Lang:t('success.successful_cutting'), "success")
     end)
end

-- events

RegisterNetEvent('keep-gunrack:server:create_gunrack', function(plate)
     local src = source
     local Player = QBCore.Functions.GetPlayer(src)

     if not IsJobAllowed(Player.PlayerData.job.name) then
          TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_authorized'), "error")
          return
     end

     if isAlreadyInstalled(plate) then
          TriggerClientEvent('QBCore:Notify', src, Lang:t('error.already_installed'), "error")
          return
     end

     local _HasItem = HasItem(src, Player, 'policegunrack')
     if not _HasItem then return end

     if not remove_item(src, Player, 'policegunrack', 1) then
          TriggerClientEvent('QBCore:Notify', src, Lang:t('error.failed_to_use_gunrack'), "error")
          return
     end

     TriggerClientEvent('QBCore:Notify', src, Lang:t('success.successful_installation'), "success")
     TriggerClientEvent('keep-gunrack:client:open_gunrack', src, plate)
end)

RegisterNetEvent('keep-gunrack:server:open_gunrack', function(plate)
     local src = source
     local Player = QBCore.Functions.GetPlayer(src)
     if not Player then return end
     if not IsJobAllowed(Player.PlayerData.job.name) then
          TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_authorized'), "error")
          return
     end

     if isAlreadyInstalled(plate) then
          if Config.gunrack.use_keys_to_unlock_gunrack then
               if does_player_have_keys(Player, plate) then
                    TriggerClientEvent('keep-gunrack:client:open_gunrack', src, plate)
               else
                    TriggerClientEvent('QBCore:Notify', src, Lang:t('error.dont_have_gunrack_keys'), "error")
               end
          else
               TriggerClientEvent('keep-gunrack:client:open_gunrack', src, plate)
          end
          return
     else
          TriggerClientEvent('QBCore:Notify', src, Lang:t('error.dont_have_a_gunrack'), "error")
          return
     end
end)
