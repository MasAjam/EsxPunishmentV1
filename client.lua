local isPunished = false
local sweepCount = 0
local totalSweeps = 0
local currentTask = 1
local isSweeping = false
local punishmentZone = vector3(233.6716, -888.1262, 30.4921)
local punishmentRadius = 50.0 -- Radius maksimal sebelum pemain dipaksa kembali

local sweepLocations = {
    vector3(233.6, -888.1, 30.4),
    vector3(237.0, -884.5, 30.4),
    vector3(241.2, -890.7, 30.4),
    vector3(229.8, -895.3, 30.4),
    vector3(223.6, -885.0, 30.4),
    vector3(235.0, -899.5, 30.4),
    vector3(228.4, -877.7, 30.4),
    vector3(245.3, -883.8, 30.4)
}

RegisterNetEvent("esx_punishment:startPunishment")
AddEventHandler("esx_punishment:startPunishment", function(sweeps)
    isPunished = true
    sweepCount = 0
    totalSweeps = sweeps
    currentTask = 1

    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, punishmentZone.x, punishmentZone.y, punishmentZone.z)
    SetPedComponentVariation(playerPed, 11, 0, 0, 2) -- Jacket 0
    SetPedComponentVariation(playerPed, 1, 49, 0, 2) -- Mask
    SetPedComponentVariation(playerPed, 4, 270, 1, 2) -- Legs 270, Texture 1
    SetPedComponentVariation(playerPed, 6, 25, 0, 2) -- Shoes 25
    
    TriggerEvent("esx:showNotification", "Kamu sedang menjalani hukuman. Pergi ke titik yang ditandai dan tekan ~y~E~s~ untuk menyapu!")

    StartSweeping()
    MonitorPlayerPosition()
end)

function StartSweeping()
    Citizen.CreateThread(function()
        while isPunished and sweepCount < totalSweeps do
            Citizen.Wait(0)
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local targetPos = sweepLocations[currentTask]

            DrawMarker(1, targetPos.x, targetPos.y, targetPos.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 255, 0, 150, false, true, 2, false, nil, nil, false)

            if #(coords - targetPos) < 1.5 and not isSweeping then
                DrawText3D(targetPos.x, targetPos.y, targetPos.z, "[E] Menyapu")

                if IsControlJustReleased(0, 38) then
                    isSweeping = true
                    StartSweepingAction()
                end
            end
        end
    end)
end

function StartSweepingAction()
    local playerPed = PlayerPedId()
    RequestAnimDict("anim@amb@drug_field_workers@rake@male_a@base")

    while not HasAnimDictLoaded("anim@amb@drug_field_workers@rake@male_a@base") do
        Citizen.Wait(100)
    end

    TaskPlayAnim(playerPed, "anim@amb@drug_field_workers@rake@male_a@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
    TriggerEvent("esx:showNotification", "Menyapu...")

    Citizen.Wait(5000) -- Menyapu selama 5 detik
    ClearPedTasks(playerPed)
    
    sweepCount = sweepCount + 1
    currentTask = currentTask + 1
    isSweeping = false

    if currentTask > #sweepLocations then
        currentTask = 1
    end

    if sweepCount >= totalSweeps then
        isPunished = false
        TriggerEvent("esx:showNotification", "Hukuman selesai! Kamu bebas.")
        TriggerServerEvent("esx_punishment:punishmentCompleted")
        TriggerServerEvent("esx_punishment:rewardPlayer") -- Memberikan hadiah setelah hukuman selesai
    else
        local remainingSweeps = totalSweeps - sweepCount
        TriggerEvent("esx:showNotification", "Sisa Hukuman Menyapu Kamu: " .. remainingSweeps)
    end
end

RegisterNetEvent("esx_punishment:endPunishment")
AddEventHandler("esx_punishment:endPunishment", function()
    isPunished = false
    isSweeping = false
    TriggerEvent("esx:showNotification", "Hukumanmu telah dibatalkan.")
    SetEntityCoords(PlayerPedId(), 260.2263, -869.5894, 29.2722)
end)

function MonitorPlayerPosition()
    Citizen.CreateThread(function()
        while isPunished do
            Citizen.Wait(2000) -- Cek setiap 2 detik
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)

            if #(coords - punishmentZone) > punishmentRadius then
                TriggerEvent("esx:showNotification", "Jangan mencoba kabur! Kamu dikembalikan ke tempat hukuman.")
                SetEntityCoords(playerPed, punishmentZone.x, punishmentZone.y, punishmentZone.z)
            end
        end
    end)
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextOutline()
    SetTextColour(255, 255, 255, 215)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

RegisterNetEvent("esx_punishment:rewardPlayer")
AddEventHandler("esx_punishment:rewardPlayer", function()
    TriggerServerEvent("esx_punishment:giveReward")
end)
