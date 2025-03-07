ESX = exports["es_extended"]:getSharedObject()

local punishedPlayers = {}

RegisterCommand("punishment", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= 'admin' then
        xPlayer.showNotification("Kamu tidak memiliki izin!")
        return
    end

    local targetId = tonumber(args[1])
    local sweepCount = tonumber(args[2])

    if targetId and sweepCount and sweepCount > 0 then
        local targetPlayer = ESX.GetPlayerFromId(targetId)
        if targetPlayer then
            punishedPlayers[targetId] = true
            TriggerClientEvent("esx_punishment:startPunishment", targetId, sweepCount)
            xPlayer.showNotification("Player ID " .. targetId .. " dihukum menyapu sebanyak " .. sweepCount .. " kali.")
        else
            xPlayer.showNotification("Player tidak ditemukan.")
        end
    else
        xPlayer.showNotification("Gunakan format: /punishment [id] [jumlah menyapu]")
    end
end, false)

RegisterCommand("unpunishment", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= 'admin' then
        xPlayer.showNotification("Kamu tidak memiliki izin!")
        return
    end

    local targetId = tonumber(args[1])

    if targetId and punishedPlayers[targetId] then
        punishedPlayers[targetId] = nil
        TriggerClientEvent("esx_punishment:endPunishment", targetId)
        xPlayer.showNotification("Hukuman untuk Player ID " .. targetId .. " telah dibatalkan.")
    else
        xPlayer.showNotification("Player tidak dalam hukuman.")
    end
end, false)

RegisterNetEvent("esx_punishment:punishmentCompleted")
AddEventHandler("esx_punishment:punishmentCompleted", function()
    local src = source
    punishedPlayers[src] = nil
    
    -- Berikan hadiah setelah hukuman selesai
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        xPlayer.addInventoryItem("burger", 5)
        xPlayer.addInventoryItem("water", 5)
        TriggerClientEvent("esx:showNotification", src, "Kamu telah menerima 5 Burger dan 5 Botol Air setelah menyelesaikan hukuman.")
    end
end)
