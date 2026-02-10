local QBCore = exports['qb-core']:GetCoreObject()

local function isPlayerAdmin(src)
    -- QBCore permission check 
    if not Config.AdminPermissions or #Config.AdminPermissions == 0 then
        return QBCore.Functions.HasPermission(src, "admin") or QBCore.Functions.HasPermission(src, "god")
    end

    for _, perm in ipairs(Config.AdminPermissions) do
        if QBCore.Functions.HasPermission(src, perm) then
            return true
        end
    end

    return false
end

RegisterNetEvent("st-adminitem:openUI", function()
    local src = source
    if not isPlayerAdmin(src) then
        TriggerClientEvent('QBCore:Notify', src, "You are not an admin!", "error")
        return
    end

    local items = {}
    for k, v in pairs(QBCore.Shared.Items or {}) do
        items[#items + 1] = {
            name = v.name,
            label = v.label or v.name
        }
    end

    TriggerClientEvent("st-adminitem:open", src, items)
end)

RegisterNetEvent("st-adminitem:give", function(item, amount, targetId)
    local src = source
    if not isPlayerAdmin(src) then
        TriggerClientEvent('QBCore:Notify', src, "You are not an admin!", "error")
        return
    end

    if type(item) ~= "string" or item == "" then
        TriggerClientEvent('QBCore:Notify', src, "Invalid item.", "error")
        return
    end

    if not QBCore.Shared.Items[item] then
        TriggerClientEvent('QBCore:Notify', src, "Item does not exist.", "error")
        return
    end

    local amt = tonumber(amount) or 1
    if amt < 1 then amt = 1 end
    if amt > (Config.MaxAmount or 1000) then amt = Config.MaxAmount or 1000 end

    local Target
    if targetId ~= nil then
        targetId = tonumber(targetId)
        if not targetId then
            TriggerClientEvent('QBCore:Notify', src, "Invalid target ID.", "error")
            return
        end
        Target = QBCore.Functions.GetPlayer(targetId)
        if not Target then
            TriggerClientEvent('QBCore:Notify', src, "Target not found.", "error")
            return
        end
    else
        Target = QBCore.Functions.GetPlayer(src)
        if not Target then
            TriggerClientEvent('QBCore:Notify', src, "Player not found.", "error")
            return
        end
    end

    local ok = Target.Functions.AddItem(item, amt)
    if not ok then
        TriggerClientEvent('QBCore:Notify', src, "Failed to add item (inventory full?).", "error")
        return
    end

    if targetId then
        TriggerClientEvent('QBCore:Notify', src, ('You gave %sx %s to ID %s'):format(amt, item, targetId), 'success')
        TriggerClientEvent('QBCore:Notify', targetId, ('You received %sx %s'):format(amt, item), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, ('You received %sx %s'):format(amt, item), 'success')
    end
end)
