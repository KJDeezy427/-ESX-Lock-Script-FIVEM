if not Config then Config = {} end

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

-- Always return true for ownership (or implement your own logic)
ESX.RegisterServerCallback('esx_keylock:isVehicleOwner', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false) end

    -- Without MySQL, just assume true or false here
    -- For example, always allow:
    cb(true)

    -- Or if you want to deny:
    -- cb(false)
end)

ESX.RegisterServerCallback('esx_keylock:hasKeyFob', function(source, cb, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false) end

    local item = xPlayer.getInventoryItem(itemName)
    cb(item and item.count > 0)
end)
