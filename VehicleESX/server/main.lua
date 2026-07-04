local svConfig = require "sv_config"
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

--- Send embed to Discord webhook
---@param webhook string
---@param embed table
local function sendDiscordEmbed(webhook, embed)
    local payload = json.encode({
        username = "Vehicle Status Bot",
        avatar_url = "https://i.imgur.com/AfFp7pu.png",
        embeds = {embed},
    })
    
    PerformHttpRequest(webhook, function(err, text, headers)
        if err < 200 or err >= 300 then
            print(("[vehiclestatus] Discord webhook error: %d - %s"):format(err, text or ""))
        end
    end, "POST", payload, {
        ["Content-Type"] = "application/json",
    })
end

--- Handle Discord send request (Sends to BOTH public and staff webhooks)
RegisterNetEvent("vehiclestatus:server:sendToDiscord", function(data)
    local src = source
    
    -- Validate player using ESX
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    -- Get player identifiers
    local license = GetPlayerIdentifierByType(src, "license")
    local discord = GetPlayerIdentifierByType(src, "discord")
    
    local vehicleInfo = data.vehicleInfo
    local mods = data.mods
    local handlingInfo = data.handlingInfo
    local note = data.note or ""
    
    -- Validate note is required
    if not note or note == "" then
        TriggerClientEvent("ox_lib:notify", src, {
            title = "Note Required",
            description = "Please add a note before submitting",
            type = "error",
        })
        return
    end
    
    -- Build Discord embed (Public format - NO plate)
    local publicEmbed = {
        title = "🚗 Vehicle Status Report",
        color = 3447003, -- Blue
        fields = {
            {
                name = "Player",
                value = data.playerName,
                inline = true,
            },
            {
                name = "Vehicle",
                value = vehicleInfo.displayName,
                inline = true,
            },
            {
                name = "Spawncode",
                value = vehicleInfo.spawncode,
                inline = true,
            },
        },
        footer = {
            text = "Vehicle Status Script",
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }
    
    -- Add speed analytics if enabled
    if config.enableSpeedAnalytics then
        publicEmbed.fields[#publicEmbed.fields + 1] = {
            name = "Speed Analysis",
            value = ("Baseline: %d mph | Upgraded: %d mph"):format(
                vehicleInfo.baselineSpeed, vehicleInfo.upgradedSpeed
            ),
            inline = true,
        }
    end
    
    -- Add note field
    publicEmbed.fields[#publicEmbed.fields + 1] = {
        name = "Note",
        value = note,
        inline = false,
    }
    
    -- Build Discord embed (Staff format - includes plate, license, discord, model hash)
    local staffEmbed = {
        title = "🚨 Staff Vehicle Report",
        color = 16711680, -- Red
        fields = {
            {
                name = "Player Info",
                value = ("%s (ID: %d)\nLicense: `%s`\nDiscord: <@%s>"):format(
                    data.playerName, data.playerId, 
                    license and license:gsub("license:", "") or "N/A",
                    discord and discord:gsub("discord:", "") or "N/A"
                ),
                inline = false,
            },
            {
                name = "Vehicle Info",
                value = ("**Display:** %s\n**Spawncode:** `%s`\n**Model Hash:** `%s`\n**Plate:** `%s`\n**Class:** %s"):format(
                    vehicleInfo.displayName,
                    vehicleInfo.spawncode,
                    vehicleInfo.modelHash,
                    vehicleInfo.plate,
                    vehicleInfo.className
                ),
                inline = false,
            },
        },
        footer = {
            text = "Vehicle Status Script - Staff Report",
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }
    
    -- Add speed analytics if enabled
    if config.enableSpeedAnalytics then
        staffEmbed.fields[#staffEmbed.fields + 1] = {
            name = "Speed Analysis",
            value = ("Baseline: %d mph | Full Upgrades: %d mph"):format(
                vehicleInfo.baselineSpeed, vehicleInfo.upgradedSpeed
            ),
            inline = true,
        }
    end
    
    -- Add modifications
    if mods and mods ~= "" then
        staffEmbed.fields[#staffEmbed.fields + 1] = {
            name = "Modifications",
            value = mods,
            inline = false,
        }
    end

    -- Add handling info if available
    if handlingInfo then
        -- Acceleration and Speed
        staffEmbed.fields[#staffEmbed.fields + 1] = {
            name = "⚡ Acceleration & Speed",
            value = string.format(
                "Accel: %.2f | Max Speed: %.2f\nfInitialDriveForce: %.4f\nfDriveInertia: %.4f\nfInitialDriveMaxFlatVel: %.2f",
                handlingInfo.acceleration,
                handlingInfo.maxSpeed,
                handlingInfo.fInitialDriveForce,
                handlingInfo.fDriveInertia,
                handlingInfo.fInitialDriveMaxFlatVel
            ),
            inline = false,
        }

        -- Brakes and Steering
        staffEmbed.fields[#staffEmbed.fields + 1] = {
            name = "🛑 Brakes & Steering",
            value = string.format(
                "fBrakeForce: %.4f\nfBrakeBiasFront: %.4f\nfHandBrakeForce: %.4f\nfSteeringLock: %.2f",
                handlingInfo.fBrakeForce,
                handlingInfo.fBrakeBiasFront,
                handlingInfo.fHandBrakeForce,
                handlingInfo.fSteeringLock
            ),
            inline = false,
        }

        -- Traction
        staffEmbed.fields[#staffEmbed.fields + 1] = {
            name = "🎯 Traction",
            value = string.format(
                "fTractionCurveMax: %.4f\nfTractionCurveMin: %.4f\nfLowSpeedTractionLossMult: %.4f\nfTractionLossMult: %.4f",
                handlingInfo.fTractionCurveMax,
                handlingInfo.fTractionCurveMin,
                handlingInfo.fLowSpeedTractionLossMult,
                handlingInfo.fTractionLossMult
            ),
            inline = false,
        }

        -- Damage Levels
        staffEmbed.fields[#staffEmbed.fields + 1] = {
            name = "💥 Damage Levels",
            value = string.format(
                "fCollisionDamageMult: %.4f\nfWeaponDamageMult: %.4f\nfDeformationDamageMult: %.4f\nfEngineDamageMult: %.4f",
                handlingInfo.fCollisionDamageMult,
                handlingInfo.fWeaponDamageMult,
                handlingInfo.fDeformationDamageMult,
                handlingInfo.fEngineDamageMult
            ),
            inline = false,
        }

        -- Suspension
        staffEmbed.fields[#staffEmbed.fields + 1] = {
            name = "🔧 Suspension",
            value = string.format(
                "fRollCentreHeightFront: %.4f\nfRollCentreHeightRear: %.4f\n**Boost: %s**",
                handlingInfo.fRollCentreHeightFront,
                handlingInfo.fRollCentreHeightRear,
                handlingInfo.hasBoost and "true" or "false"
            ),
            inline = false,
        }
    end

    -- Add note field
    staffEmbed.fields[#staffEmbed.fields + 1] = {
        name = "Note",
        value = note,
        inline = false,
    }
    
    -- Send to public Discord
    if svConfig.publicWebhook and svConfig.publicWebhook ~= "" and svConfig.publicWebhook ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" then
        sendDiscordEmbed(svConfig.publicWebhook, publicEmbed)
    else
        print("[vehiclestatus] Public Discord webhook not configured. Add URL to sv_config.lua")
    end
    
    -- Send to staff Discord
    if svConfig.staffWebhook and svConfig.staffWebhook ~= "" then
        sendDiscordEmbed(svConfig.staffWebhook, staffEmbed)
    else
        print("[vehiclestatus] Staff Discord webhook not configured. Add URL to sv_config.lua")
    end
end)

--- Handle separate staff Discord send request (kept for backward compatibility)
RegisterNetEvent("vehiclestatus:server:sendStaffReport", function(data)
    -- This event is now deprecated - both webhooks are sent via sendToDiscord
    -- Kept here for backward compatibility if any old clients call it
end)
