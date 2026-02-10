local isAdmin = false

RegisterNetEvent("st-adminitem:setAdmin", function(status)
    isAdmin = status
end)

RegisterCommand("giveitemui", function()
    TriggerServerEvent("st-adminitem:openUI")
end)
RegisterKeyMapping("giveitemui", "Admin Item Giver UI", "keyboard", "F7")

RegisterNetEvent("st-adminitem:open", function(items)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "open",
        items = items
    })
end)

-- NUI callbacks
RegisterNUICallback("giveItem", function(data, cb)
    if data and data.item and data.amount then
        local item = tostring(data.item)
        local amount = tonumber(data.amount) or 1
        local target = data.target and tonumber(data.target) or nil
        TriggerServerEvent("st-adminitem:give", item, amount, target)
    end
    cb({})
end)

RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

-- ESC from NUI (optional explicit callback if you want to call it from JS)
RegisterNUICallback("escape", function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

-- Optional: when resource stops, clear focus
AddEventHandler('onResourceStop', function(resName)
    if GetCurrentResourceName() ~= resName then return end
    SetNuiFocus(false, false)
end)
