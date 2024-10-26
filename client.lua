local isSpraying, isBusy = false, {}


--███████╗███╗   ███╗██████╗     ██████╗ ███████╗███████╗ ██████╗ ██╗   ██╗██████╗  ██████╗███████╗███████╗
--██╔════╝████╗ ████║██╔══██╗    ██╔══██╗██╔════╝██╔════╝██╔═══██╗██║   ██║██╔══██╗██╔════╝██╔════╝██╔════╝
--███████╗██╔████╔██║██████╔╝    ██████╔╝█████╗  ███████╗██║   ██║██║   ██║██████╔╝██║     █████╗  ███████╗
--╚════██║██║╚██╔╝██║██╔═══╝     ██╔══██╗██╔══╝  ╚════██║██║   ██║██║   ██║██╔══██╗██║     ██╔══╝  ╚════██║
--███████║██║ ╚═╝ ██║██║         ██║  ██║███████╗███████║╚██████╔╝╚██████╔╝██║  ██║╚██████╗███████╗███████║
--╚══════╝╚═╝     ╚═╝╚═╝         ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚══════╝╚══════╝





RegisterNetEvent('smp_paints:client:stopPaint', function(id)
    if #(GetEntityCoords(PlayerPedId()) - Config.Locations[id].control) <= 15.0 then
        isSpraying = false
    end
end)

Citizen.CreateThread(function()
    for k, v in ipairs(Config.Locations) do  end
local lak = true
    if lak then
        for k, v in ipairs(Config.Locations) do
            exports.ox_target:addSphereZone({
                coords = v.control,
                radius = 0.5,

                options = {
                    {
                        label = Locales.target,
                        name = 'paint_job',
                        distance = 2.0,
                        canInteract = function(entity, distance, coords, bone)
                            return DoesHaveRequiredJob(k)
                        end,
                        onSelect = function()
                            lakovna(k)
                        end
                    }
                }
            })
        end
    else
        while true do
            local coords = GetEntityCoords(PlayerPedId())

            for k, v in ipairs(Config.Locations) do
                local distance = #(coords - v.control)

                if distance <= 15 and DoesHaveRequiredJob(k) then
                    currLocation = k
                end
            end

            Citizen.Wait(1000)
        end
    end
end)

local currLocation


RegisterNetEvent('smp_paints:client:taken', function(pos, value)
    isBusy[pos] = value
end)

DoesHaveRequiredJob = function(pos)
    if not Config.Locations[pos].jobs then return true end

    for k, v in ipairs(Config.Locations[pos].jobs) do
        if v == _GetPlayerJobName() then
            return true
        end
    end

    return false
end

RegisterNetEvent('smp_paints:client:lakovna', function(id, vehicle, color, isPrimary)
    if #(GetEntityCoords(PlayerPedId()) - Config.Locations[id].control) <= 15.0 then
        PaintVehicle(NetToVeh(vehicle), color, isPrimary)
        isSpraying = true
    end
end)


NalakovatAuto = function(hex)
    hex = hex:gsub('#', '')
    return { r = tonumber('0x' .. hex:sub(1, 2)), g = tonumber('0x' .. hex:sub(3, 4)), b = tonumber('0x' .. hex:sub(5, 6)) }
end


GetVehicleInSprayCoords = function(location)
    local closestVehicle, closestDistance = _GetClosestVehicle(location)

    if closestVehicle ~= -1 and closestDistance <= 2.0 then return closestVehicle end
    
    return nil
end

PaintVehicle = function(vehicle, color, primary)
    local r, g, b

    if primary then r, g, b = GetVehicleCustomPrimaryColour(vehicle)
    else r, g, b = GetVehicleCustomSecondaryColour(vehicle) end

    Citizen.CreateThread(function()
        isSpraying = true
        lib.notify({
            title = 'Car Paint',
            description = Locales.notify,
            type = 'success'
        })
         lib.progressBar({
            duration = 4000,
            label = Locales.progress,
        })
     
        while r ~= color.r or g ~= color.g or b ~= color.b do
            Citizen.Wait(40)
            

            r = color.r ~= r and (color.r > r and r + 1 or r - 1) or r
            g = color.g ~= g and (color.g > g and g + 1 or g - 1) or g
            b = color.b ~= b and (color.b > b and b + 1 or b - 1) or b

            if primary then SetVehicleCustomPrimaryColour(vehicle, r, g, b)
            else SetVehicleCustomSecondaryColour(vehicle, r, g, b) end
        end
        

        isSpraying = false
        lib.notify({
            title = 'Car Paint',
            description = Locales.success,
            type = 'info'
        })
    end)
end

ESX = exports['es_extended']:getSharedObject()


_GetClosestVehicle = function(location)
    return ESX.Game.GetClosestVehicle(location)
end

_GetPlayerJobName = function()
    return ESX.GetPlayerData().job.name
end


lakovna = function(pos)
    currLocation = pos
    local vehicle = GetVehicleInSprayCoords(Config.Locations[pos].vehicle)

    if not vehicle then return  lib.notify({
        title = 'Car Paint',
        description = 'Theres no vehicle nearby!',
        type = 'error'
    }) end
    TriggerServerEvent('smp_paints:server:taken', pos, true)

    local input = lib.inputDialog(Locales.Lakovna, {
        { type = 'select', label = Locales.menu, options = {
            { value = 'primary', label = 'Primary' },
            { value = 'secondary', label = 'Secondary' }
        }, default = 'primary', clearable = false },
        { type = 'select', label = 'Type', options = {
            { value = '0', label = 'Normal' },
            { value = '1', label = 'Metalic' },
            { value = '2', label = 'Pearl' },
            { value = '3', label = 'Matte' },
            { value = '4', label = 'Metal' },
            { value = '5', label = 'Chrome' },
        }, default = '0', clearable = false },
        { type = 'color', label = 'Colour', default = '#ffffff' }
    })

    if not input then
        TriggerServerEvent('smp_paints:server:taken', pos, false)
        return
    end

    local isPrimary = input[1] == 'primary'

    if isPrimary then
        SetVehicleModColor_1(vehicle, tonumber(input[2]), 0, 0)
        SetVehicleExtraColours(vehicle, 0, 0)
    else
        SetVehicleModColor_2(vehicle, tonumber(input[2]), 0)
    end

    TriggerServerEvent('smp_paints:server:lakovna', pos, VehToNet(vehicle), NalakovatAuto(input[3]), isPrimary)

    Citizen.CreateThread(function()
        Citizen.Wait(1000)
        while isSpraying do Citizen.Wait(100) end

        TriggerServerEvent('smp_paints:server:Busy', pos, false)
        TriggerServerEvent('smp_paints:server:stopPaint', pos)
    end)
end


--███████╗███╗   ███╗██████╗     ██████╗ ███████╗███████╗ ██████╗ ██╗   ██╗██████╗  ██████╗███████╗███████╗
--██╔════╝████╗ ████║██╔══██╗    ██╔══██╗██╔════╝██╔════╝██╔═══██╗██║   ██║██╔══██╗██╔════╝██╔════╝██╔════╝
--███████╗██╔████╔██║██████╔╝    ██████╔╝█████╗  ███████╗██║   ██║██║   ██║██████╔╝██║     █████╗  ███████╗
--╚════██║██║╚██╔╝██║██╔═══╝     ██╔══██╗██╔══╝  ╚════██║██║   ██║██║   ██║██╔══██╗██║     ██╔══╝  ╚════██║
--███████║██║ ╚═╝ ██║██║         ██║  ██║███████╗███████║╚██████╔╝╚██████╔╝██║  ██║╚██████╗███████╗███████║
--╚══════╝╚═╝     ╚═╝╚═╝         ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚══════╝╚══════╝