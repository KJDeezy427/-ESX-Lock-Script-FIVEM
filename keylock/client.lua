local ESX = nil

CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(200)
    end
end)

if not Config then Config = {} end

local function notify(message, type)
    local notifType = Config.NotificationType

    if notifType == 'ox' then
        exports.ox_lib:notify({
            title = 'Vehicle Lock',
            description = message,
            type = type or 'inform' -- 'success', 'error', 'inform'
        })
    elseif notifType == 'esx' then
        ESX.ShowNotification(message)
    else -- chat
        TriggerEvent('chat:addMessage', {
            color = { 0, 153, 255 },
            multiline = true,
            args = { "Vehicle Lock", message }
        })
    end
end

local function playKeyFobAnim()
    local playerPed = PlayerPedId()
    RequestAnimDict("anim@mp_player_intmenu@key_fob@")
    while not HasAnimDictLoaded("anim@mp_player_intmenu@key_fob@") do
        Wait(10)
    end
    TaskPlayAnim(playerPed, "anim@mp_player_intmenu@key_fob@", "fob_click", 8.0, -8, -1, 50, 0, false, false, false)
    Wait(1000)
    ClearPedTasks(playerPed)
end

RegisterCommand("lock", function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        vehicle = GetClosestVehicle(GetEntityCoords(playerPed), 5.0, 0, 71)
    end

    if vehicle and vehicle ~= 0 then
        local plate = GetVehicleNumberPlateText(vehicle):gsub("%s+", "")

        if Config.RequireKeyItem then
            ESX.TriggerServerCallback('esx_keylock:hasKeyFob', function(hasItem)
                if hasItem then
                    attemptLock(vehicle, plate)
                else
                    notify("You need a key fob to lock/unlock this vehicle.", "error")
                end
            end, Config.RequiredItemName)
        else
            attemptLock(vehicle, plate)
        end
    else
        notify("No vehicle nearby to lock or unlock.", "error")
    end
end, false)

function attemptLock(vehicle, plate)
    ESX.TriggerServerCallback('esx_keylock:isVehicleOwner', function(isOwner)
        if isOwner then
            local lockStatus = GetVehicleDoorLockStatus(vehicle)
            if lockStatus == 1 or lockStatus == 0 then
                SetVehicleDoorsLocked(vehicle, 2)
                SetVehicleLights(vehicle, 2)
                Wait(300)
                SetVehicleLights(vehicle, 0)
                playKeyFobAnim()
                PlaySoundFromEntity(-1, "REMOTE_LOCK", vehicle, "REMOTE_CONTROL_UNLOCK_SOUNDS", 0, 0)
                notify("You locked your vehicle.", "success")
            else
                SetVehicleDoorsLocked(vehicle, 1)
                SetVehicleLights(vehicle, 2)
                Wait(300)
                SetVehicleLights(vehicle, 0)
                playKeyFobAnim()
                PlaySoundFromEntity(-1, "REMOTE_UNLOCK", vehicle, "REMOTE_CONTROL_UNLOCK_SOUNDS", 0, 0)
                notify("You unlocked your vehicle.", "info")
            end
        else
            notify("You do not own this vehicle.", "error")
        end
    end, plate)
end

-- Keybind: U (303)
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustReleased(0, 303) then
            ExecuteCommand("lock")
        end
    end
end)
