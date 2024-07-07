local animationDict = "pickup_object"
local animation = "pickup_low"

local function LoadModel(model)
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Wait(10)
    end
end

local function LoadAnimationDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

local function RequestNetworkControlOfObject(netId, itemEntity)
    if NetworkDoesNetworkIdExist(netId) then
        NetworkRequestControlOfNetworkId(netId)
        while not NetworkHasControlOfNetworkId(netId) do
            Wait(100)
            NetworkRequestControlOfNetworkId(netId)
        end
    end

    if DoesEntityExist(itemEntity) then
        NetworkRequestControlOfEntity(itemEntity)
        while not NetworkHasControlOfEntity(itemEntity) do
            Wait(100)
            NetworkRequestControlOfEntity(itemEntity)
        end
    end
end


---@param carEntity - The entity of the car to get the metadata for
---@return table - The metadata of the car {plate, colorPrimary, colorSecondary, pearlescentColor, wheelColor, xenonColor}
local function getCarMetadata(carEntity)
    local carPlate = GetVehicleNumberPlateText(carEntity)
    local colorPrimary, colorSecondary = GetVehicleColours(carEntity)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(carEntity)
    local xenonColor = GetVehicleXenonLightsColour(carEntity)

    return {
        plate = carPlate,
        colorPrimary = colorPrimary,
        colorSecondary = colorSecondary,
        pearlescentColor = pearlescentColor,
        wheelColor = wheelColor,
        xenonColor = xenonColor,
    }
end


---@param car - The car entity to set the properties on
---@param carMetadata - The metadata of the car {plate, colorPrimary, colorSecondary, pearlescentColor, wheelColor, xenonColor}, may be nil for frameworks that dont support item metadata (ex: ESX)
local function setCarProperties(car, carMetadata)
    if not carMetadata then return end

    local plate = carMetadata.plate
    local colorPrimary = carMetadata.colorPrimary
    local colorSecondary = carMetadata.colorSecondary
    local pearlescentColor = carMetadata.pearlescentColor
    local wheelColor = carMetadata.wheelColor
    local xenonColor = carMetadata.xenonColor


    if not carPlate then
        carPlate = "LOVELY".. math.random(1000, 9999)
    end
    SetVehicleNumberPlateText(car, carPlate)

    SetVehicleColours(car, colorPrimary, colorSecondary)
    SetVehicleExtraColours(car, pearlescentColor, wheelColor)


    if xenonColor ~= 255 then
        ToggleVehicleMod(car, 22, true)
        SetVehicleXenonLightsColour(car, xenonColor)
    end
end


---@param carModel string The model of the car to spawn
---@param carItemData table The item data of the car to spawn
RegisterNetEvent('lovely-cars-as-items:client:place', function(carModel, carItemData)
    local ped = PlayerPedId()
    local itemMetadata = GetItemMetadata(carItemData)

 
    LoadModel(carModel)

    ClearPedTasks(ped)
    TaskPlayAnim(ped, animationDict, animation , 8.0, -8.0, -1, 0, 0, false, false, false)

 
    Wait(500)

   
    local offsetCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)
    local car = CreateVehicle(carModel, offsetCoords, GetEntityHeading(ped), true, false)
    SetVehicleOnGroundProperly(car)

    TriggerServerEvent("lovely-cars-as-items:server:RemoveItem", carModel)

    setCarProperties(car, itemMetadata)
    
    SetModelAsNoLongerNeeded(carModel)

    local carPlate = GetVehicleNumberPlateText(car)
    if itemMetadata then
        carPlate = itemMetadata.plate
    end
    SetPlayerAsOwnerOfVehicleWithPlate(carPlate)
end)


---@param data table The data of the car entity to pick up provided from the target event
RegisterNetEvent('lovely-cars-as-items:client:pickup', function(data)
    local ped = PlayerPedId()
    local carEntity = data.entity
    local carItem = data.itemName
    
    if carEntity then
        local carEntityModelId = GetEntityModel(carEntity)
        local carNetId = NetworkGetNetworkIdFromEntity(carEntity)
        local carMetadata = getCarMetadata(carEntity)

        LoadAnimationDict(animationDict)

        ClearPedTasks(ped)
        TaskPlayAnim(ped, animationDict, animation , 8.0, -8.0, -1, 0, 0, false, false, false)

        TriggerServerEvent("lovely-cars-as-items:server:AddItem", carItem, carMetadata)


        RequestNetworkControlOfObject(carNetId, carEntity)

        DeleteEntity(carEntity)
    end
end)



for _, car in pairs(Config.Cars) do
    local targetOptions = {
        {
            type = 'client',
            event = "lovely-cars-as-items:client:pickup",
            icon = "fas fa-car",
            label = "Pick up car",
            itemName = car,
        },
    }


    AddTargetModel(car, {
        options = targetOptions,
        distance = 2.0
    })
end
