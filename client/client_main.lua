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
PlayerJob = nil
local onDuty = nil

-- fucntions

local function isVehicleAllowed(veh)
     local class = GetVehicleClass(veh)
     local model = GetEntityModel(veh)

     for _, w_model in ipairs(Config.gunrack.whitelist.models) do
          if GetHashKey(w_model) == model then return true end
     end

     for _, w_class in ipairs(Config.gunrack.whitelist.classes) do
          if w_class == class then return true end
     end
     return false
end

local function makeEntityFaceEntity(entity1, entity2)
     local p1 = GetEntityCoords(entity1, true)
     local p2 = GetEntityCoords(entity2, true)

     local dx = p2.x - p1.x
     local dy = p2.y - p1.y

     local heading = GetHeadingFromVector_2d(dx, dy)
     TaskAchieveHeading(entity1, heading, -1)
     -- SetEntityHeading(entity1, heading)
end

local function get_closest_vehicle_helper(coords)
     -- it's a modifed qb-core's function
     local ped = PlayerPedId()
     local vehicles = GetGamePool('CVehicle')
     local closestDistance = -1
     local closestVehicle = -1

     if not coords then
          coords = GetEntityCoords(ped)
     end

     for i = 1, #vehicles, 1 do
          local vehicleCoords = GetEntityCoords(vehicles[i])
          local distance = #(vehicleCoords - coords)

          if closestDistance == -1 or closestDistance > distance then
               closestVehicle = vehicles[i]
               closestDistance = distance
          end
     end
     return closestVehicle, closestDistance
end

local function get_closest_vehicle()
     local player_ped = PlayerPedId()
     local veh, dis = get_closest_vehicle_helper()
     makeEntityFaceEntity(player_ped, veh)
     return veh, dis
end

local function get_vehicle_player_is_in()
     local player_ped = PlayerPedId()
     if not IsPedInAnyVehicle(player_ped, false) then return nil end
     return GetVehiclePedIsIn(player_ped, false)
end

local function get_vehicle()
     local player_ped = PlayerPedId()
     local veh = nil
     local distance = 0

     if IsPedInAnyVehicle(player_ped, false) then
          veh = get_vehicle_player_is_in()
     else
          veh, distance = get_closest_vehicle()
     end

     if isVehicleAllowed(veh) then
          return veh, distance
     else
          QBCore.Functions.Notify(Lang:t('error.vehicle_is_not_allowed'), "error")
          return nil, nil
     end
end

local function get_vehicle_menu()
     local player_ped = PlayerPedId()
     local veh = nil
     local distance = 0

     if not IsPedInAnyVehicle(player_ped, false) then
          return
     end

     veh = get_vehicle_player_is_in()
     if isVehicleAllowed(veh) then
          return veh, distance
     else
          return nil, nil
     end
end

local function installing_gunrack()
     local duration = Config.gunrack.install_duration * 1000
     local veh, distance = get_vehicle()
     local plate = GetVehicleNumberPlateText(veh)
     if not veh then return end
     if not plate then
          QBCore.Functions.Notify(Lang:t('error.failed_to_read_plate'), "error")
          return
     end
     TriggerEvent('animations:client:EmoteCommandStart', { "mechanic4" })

     QBCore.Functions.Progressbar("keep_gunrack_install", Lang:t('progressbar.installing_gun_rack'), duration, false,
          false, {
               disableMovement = true,
               disableCarMovement = true,
               disableMouse = false,
               disableCombat = true
          }, {}, {}, {}, function()
          TriggerEvent('animations:client:EmoteCommandStart', { "c" })
          TriggerServerEvent('keep-gunrack:server:create_gunrack', plate)
     end)
end

local function open_stash(plate)
     if Config.gunrack.while_open_animation then
          TriggerEvent('animations:client:EmoteCommandStart', { "mechanic4" })
     end
     local settings = { maxweight = Config.gunrack.size, slots = Config.gunrack.slots }
     TriggerServerEvent("inventory:server:OpenInventory", "stash", "Gunrack_" .. plate, settings)
     TriggerEvent("inventory:client:SetCurrentStash", "Gunrack_" .. plate)

     if Config.gunrack.while_open_animation then
          Wait(3500)
          repeat
               Wait(1000)
          until IsNuiFocused() == false
          TriggerEvent('animations:client:EmoteCommandStart', { "c" })
     end
end

-- events

RegisterNetEvent('keep-gunrack:client:start_installing_gunrack', function()
     -- technically we won't need to check for item but just in case
     QBCore.Functions.TriggerCallback("QBCore:HasItem", function(hasitem)
          if not hasitem then return end
          installing_gunrack()
     end, 'policegunrack')
end)

RegisterNetEvent("keep-gunrack:client:open_gunrack", function(plate)
     if not plate then return end
     local duration = Config.gunrack.opening_duration
     QBCore.Functions.Progressbar("keep_gunrack_opening", Lang:t('progressbar.opening_gun_rack'), duration * 1000,
          false, false, {
               disableMovement = true,
               disableCarMovement = false,
               disableMouse = false,
               disableCombat = true
          }, {}, {}, {}, function()
          open_stash(plate)
     end)
end)

AddEventHandler("keep-gunrack:client:open_gunrack_menu", function()
     local player_ped = PlayerPedId()
     local veh = nil

     if IsPedInAnyVehicle(player_ped, false) then
          veh = get_vehicle_player_is_in()
     else
          QBCore.Functions.Notify(Lang:t('error.must_be_in_vehicle'), "error")
          return
     end

     local plate = GetVehicleNumberPlateText(veh)

     if not plate then return end

     if not isVehicleAllowed(veh) then
          QBCore.Functions.Notify(Lang:t('error.vehicle_is_not_allowed'), "error")
          return
     end
     TriggerServerEvent('keep-gunrack:server:open_gunrack', plate)
end)

AddEventHandler('onResourceStart', function(resourceName)
     if (GetCurrentResourceName() ~= resourceName) then return end

     QBCore.Functions.GetPlayerData(function(PlayerData)
          PlayerJob = PlayerData.job
          if IsJobAllowed(PlayerJob.name) then
               onDuty = PlayerData.job.onduty
          end
     end)
end)

AddEventHandler('onResourceStop', function(resourceName)
     if (GetCurrentResourceName() ~= resourceName) then return end
     Menu:destroy()
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
     QBCore.Functions.GetPlayerData(function(PlayerData)
          PlayerJob = PlayerData.job
          if IsJobAllowed(PlayerJob.name) then
               onDuty = PlayerData.job.onduty
          end
     end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
     PlayerJob = JobInfo
     if IsJobAllowed(PlayerJob.name) then
          onDuty = PlayerJob.onduty
     end
end)


if Config.gunrack.use_keys_to_unlock_gunrack then
     local duration = Config.gunrack.cutting_duration * 1000
     RegisterNetEvent('keep-gunrack:client:cut_key', function()
          local inputData = exports['qb-input']:ShowInput({
               header = 'Key Cutting Input',
               inputs = {
                    {
                         type = 'text',
                         isRequired = true,
                         name = 'PLATE',
                         text = 'Enter vehicle plate'
                    },
               }
          })
          if inputData then
               if not inputData.PLATE then return end
               TriggerServerEvent('keep-gunrack:server:start_cut_key', inputData.PLATE)
          end
     end)

     RegisterNetEvent('keep-gunrack:client:keycuttingmachine_animation', function(plate)
          QBCore.Functions.Progressbar("keep_gunrack_keycuttingmachine", Lang:t('progressbar.cutting_key'),
               duration, false
               ,
               false, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true
               }, {}, {}, {}, function()
               TriggerServerEvent('keep-gunrack:server:cut_key', plate)
          end)
     end)
end

CreateThread(function()
     repeat Wait(500) until PlayerJob ~= nil
     while true do
          local veh = get_vehicle_menu()
          if veh then
               if IsJobAllowed(PlayerJob.name) then
                    Menu:create()
               end
          else
               Menu:destroy()
          end
          Wait(500)
     end
end)
