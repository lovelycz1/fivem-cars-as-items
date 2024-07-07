
for _, v in pairs(Config.Cars) do
    CreateUseableItem(v, function(source, item)
        TriggerClientEvent('lovely-cars-as-items:client:place', source, item.name, item)
    end)
end

RegisterNetEvent("lovely-cars-as-items:server:RemoveItem", function(itemName)
    local src = source
    RemoveItem(src, itemName, 1)
end)

RegisterNetEvent("lovely-cars-as-items:server:AddItem", function(itemName, itemInfo)
    local src = source
    AddItem(src, itemName, 1, itemInfo)
end)
