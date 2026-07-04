local utils = require "shared.utils"
local config = require "config"

local ESX = nil

-- Wait for ESX to be ready
CreateThread(function()
    while ESX == nil do
        TriggerEvent("esx:getSharedObject", function(obj)
            ESX = obj
        end)
        Wait(0)
    end
end)

---@type VehicleInfo
local currentVehicleInfo = nil

---@type table
local currentHandlingInfo = nil

--- Send vehicle status to Discord (both public and staff webhooks)
---@param vehicleInfo VehicleInfo
---@param mods table
---@param handlingInfo table
---@param note string
local function sendToDiscord(vehicleInfo, mods, handlingInfo, note)
    if not vehicleInfo then return end

    -- Get player info from ESX
    local xPlayer = ESX.GetPlayerData()
    local playerName = xPlayer.name or "Unknown"
    local playerId = GetPlayerServerId(PlayerId())

    -- Build mod list string
    local modList = ""
    for _, modData in pairs(mods) do
        local currentStatus = modData.current <= 0 and "Stock" or tostring(modData.current)
        modList = modList .. ("%s Level: %s\n"):format(modData.name, currentStatus)
    end

    if modList == "" then
        modList = "No modifications"
    end

    -- Prepare data for server
    local data = {
        playerName = playerName,
        playerId = playerId,
        vehicleInfo = vehicleInfo,
        mods = modList,
        handlingInfo = handlingInfo,
        note = note,
    }

    -- Send to server (sends to both public and staff webhooks)
    TriggerServerEvent("vehiclestatus:server:sendToDiscord", data)
end

--- Show the vehicle status menu
local function showStatusMenu()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not vehicle or vehicle == 0 then
        exports.ox_lib:notify({
            title = "Not in Vehicle",
            description = "You must be in a vehicle to use this command",
            type = "error",
        })
        return
    end

    -- Get vehicle information
    local vehicleInfo = utils.getVehicleInfo(vehicle)
    if not vehicleInfo then return end

    -- Get current mods
    local mods = utils.getVehicleMods(vehicle)
    vehicleInfo.currentMods = mods

    -- Get handling info for staff reports
    currentHandlingInfo = utils.getVehicleHandlingInfo(vehicle)

    -- Calculate upgraded speed if analytics enabled
    if config.enableSpeedAnalytics then
        vehicleInfo.upgradedSpeed = utils.calculateUpgradedSpeed(vehicle, vehicleInfo.baselineSpeed)
    else
        vehicleInfo.upgradedSpeed = vehicleInfo.baselineSpeed
    end

    currentVehicleInfo = vehicleInfo

    -- Open NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        data = vehicleInfo
    })
end

--- NUI Callbacks
RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    cb("ok")
end)

RegisterNUICallback("reportToDiscord", function(data, cb)
    local note = data and data.note or ""
    
    -- Validate note is required
    if not note or note == "" then
        exports.ox_lib:notify({
            title = "Note Required",
            description = "Please add a note before submitting",
            type = "error",
        })
        cb("ok")
        return
    end
    
    if currentVehicleInfo then
        -- Send to both public and staff Discord webhooks
        sendToDiscord(currentVehicleInfo, currentVehicleInfo.currentMods, currentHandlingInfo, note)
        
        -- Show notification after successful send
        exports.ox_lib:notify({
            title = "Reports Sent",
            description = "Vehicle status has been sent to both public and staff channels",
            type = "success",
        })
    end
    cb("ok")
end)

-- Remove the old staff report callback since we're combining both into one
RegisterNUICallback("reportToStaff", function(_, cb)
    cb("ok")
end)

--- Command registration
RegisterCommand("status", function()
    showStatusMenu()
end, false)

-- Add chat suggestion
RegisterKeyMapping("status", "Show Vehicle Status", "keyboard", "k")

-- Wait for ox_lib to be ready
CreateThread(function()
    while not exports.ox_lib do
        Wait(100)
    end
    exports.ox_lib:notify({
        title = "Vehicle Status",
        description = "Press K or use /status to view vehicle information",
        type = "inform",
    })
end)
