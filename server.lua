local ESX = exports['es_extended']:getSharedObject()
local stancedVehicles = {}
local lastChecked = {}
local vehiclesTable = "owned_vehicles"

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(source, xPlayer, _, _)
  TriggerClientEvent("az:stancekit:playerReady", source)
end)

ESX.RegisterUsableItem(Config.StanceItem, function(source, item)
  local src = source
  local veh = GetVehiclePedIsIn(GetPlayerPed(src), false)
  if veh == 0 then
    TriggerClientEvent("az:stancekit:showHelp", src, "STANCEKIT_HELP_INSTALL_NEED_IN_CAR")
    return
  end
  if Entity(veh).state.vehicle_stance then
    TriggerClientEvent("az:stancekit:showHelp", src, "STANCEKIT_HELP_ALREADY_INSTALLED")
    return
  end
  Entity(veh).state:set("vehicle_stance", {}, true)
  local Player = ESX.GetPlayerFromId(src)
  if not Player then return end
  if not Player.removeInventoryItem(Config.StanceItem, 1) then return end
  TriggerClientEvent("az:stancekit:showHelp", src, "STANCEKIT_HELP_INSTALL_COMPLETED")
end)

RegisterNetEvent('az:stance:enteredVehicle', function(netId, plate)
  if lastChecked[netId] then
    if lastChecked[netId] + (1000 * 60) > GetGameTimer() then return end
  end
  lastChecked[netId] = GetGameTimer()
  local entityId = NetworkGetEntityFromNetworkId(netId)
  if stancedVehicles[entityId] then return end
  
  local rows = MySQL.query.await('SELECT * FROM ' .. vehiclesTable .. ' WHERE plate = ? AND has_stance = 1 LIMIT 1', {plate})
  if #rows > 0 then
    Entity(entityId).state:set("vehicle_stance", json.decode(rows[1].stance_mods))
  end
end)

RegisterNetEvent('az:stance:removeStance', function(plate)
  local remover = source
  MySQL.query.await('UPDATE ' .. vehiclesTable .. ' SET has_stance = 0, stance_mods = "{}" WHERE plate = ? LIMIT 1', {plate})
  for k, v in pairs(stancedVehicles) do
    if v.plate == plate then
      Entity(k).state:set("vehicle_stance", nil, true)
    end
  end
  if remover ~= 0 then
    TriggerClientEvent("az:stancekit:showHelp", remover, "STANCEKIT_HELP_UNINSTALLED")
    local Player = ESX.GetPlayerFromId(remover)
    if not Player then return end
    if not Player.Functions.AddItem(Config.StanceItem, 1) then return end
  end
end)

local function saveVehicleStance(plate, data)
  MySQL.query.await('UPDATE ' .. vehiclesTable .. ' SET has_stance = 1, stance_mods = ? WHERE plate = ?', { json.encode(data), plate })
  
end

AddStateBagChangeHandler('vehicle_stance' , nil , function(bagName, key, value)
  local entity = GetEntityFromStateBagName(bagName)
  if not DoesEntityExist(entity) then return end
  if not stancedVehicles[entity] then
    stancedVehicles[entity] = {}
  end
  if not value then
    stancedVehicles[entity] = nil
    return
  end
  stancedVehicles[entity].data = value
  stancedVehicles[entity].saved = false
  stancedVehicles[entity].plate = GetVehicleNumberPlateText(entity)
end)

-- 定期存在チェック
CreateThread(function()
  while true do
    for veh, val in pairs(stancedVehicles) do
      if not DoesEntityExist(veh) then
        saveVehicleStance(val.plate, val.data)
        stancedVehicles[veh] = nil
      end
    end
    Wait(0)
  end
end)

-- --FIXME: remove
-- CreateThread(function()
--   while true do
--     
--     Wait(10 * 1000)
--   end
-- end)

-- 定期保存処理
CreateThread(function()
  while true do
    for veh, val in pairs(stancedVehicles) do
      if not val.saved then
        saveVehicleStance(val.plate, val.data)
        stancedVehicles[veh].saved = true
      end
    end
    Wait(15 * 1000)
  end
end)
