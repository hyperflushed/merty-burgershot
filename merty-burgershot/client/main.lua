ESX = nil
local display = false
local ok = false
CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:GetSharedObject', function(obj) ESX = obj end)
        Wait(5)
    end
end)

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end




RegisterNUICallback("order", function(data)
    print(data.item.. " : " ..data.amount.. ": $ " ..data.price)
    TriggerServerEvent('ev-blackmarket:makeorder', data)
    TriggerEvent('arac:teslimat' , data.item, data.count)
    TriggerEvent('notification', "Go to front side of Burgershot. You will see a car.", 1)
end)


-- ITEM USABLE

RegisterNUICallback("exit", function(data)
    open(false)
end)

function open(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end


RegisterCommand('blackmarket', function()
    open(true)

end)
CreateThread(function()
    while display do
        Wait(0)
        DisableControlAction(0, 1, display) -- LookLeftRight
        DisableControlAction(0, 2, display) -- LookUpDown
        DisableControlAction(0, 142, display) -- MeleeAttackAlternate
        DisableControlAction(0, 18, display) -- Enter
        DisableControlAction(0, 322, display) -- ESC
        DisableControlAction(0, 106, display) -- VehicleMouseControlOverride
    end
end)



function knockDoorAnim()
    local knockAnimLib = "anim@heists@prison_heiststation@cop_reactions"
    local knockAnim = "cop_b_idle"
    local PlayerPed = GetPlayerPed(-1)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "knock_door", 0.2)
    Wait(100)
    while (not HasAnimDictLoaded(knockAnimLib)) do
        RequestAnimDict(knockAnimLib)
        Wait(100)
    end
    TaskPlayAnim(PlayerPed, knockAnimLib, knockAnim, 3.0, 3.0, -1, 1, 0, false, false, false )
    Wait(3500)
    TaskPlayAnim(PlayerPed, knockAnimLib, "exit", 3.0, 3.0, -1, 1, 0, false, false, false)
    open(true)
end




CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local Pos = GetEntityCoords(ped)
        local distance = #(vector3(-1192.4886474609,-901.51361083984,14.199788093567) - vector3(Pos))
        if distance < 3 then
            DrawText3D(-1192.4886474609,-901.51361083984,14.199788093567, '~g~E~s~ - Shop For Burgershot')
            if IsControlJustPressed(0, 38) then
                knockDoorAnim()
                -- TriggerEvent("arac:teslimat")
            end
        end
        Wait(5)
    end
end)

---- Car thing

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
     Citizen.Wait(5)
    end
end

RegisterNetEvent("arac:teslimat")
AddEventHandler("arac:teslimat", function(item, count)
    Citizen.Wait(0)
    local hash = GetHashKey('s_m_m_postal_01')
	local myPed = PlayerPedId()
	local player = PlayerId()
	local vehicle = GetHashKey('youga2')
	RequestModel(vehicle)
	while not HasModelLoaded(vehicle) do
		Wait(1)
	end
    RequestModel(hash)
	while not HasModelLoaded(hash) do Citizen.Wait(1) end
    
	local coords = GetOffsetFromEntityInWorldCoords(myPed, 0, 15.0, 0)
	local spawned_car = CreateVehicle(vehicle, -1169.697265625,-894.84881591797,13.921717643738, 30.0, true, false)
    local ped = CreatePedInsideVehicle(spawned_car, 4, hash, -1, true, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, 0)
    SetPedDropsWeaponsWhenDead(ped, false)
    SetPedDiesWhenInjured(ped, false)
    SetEntityInvincible(ped , true)
    FreezeEntityPosition(ped, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetEntityAsMissionEntity(spawned_car, true, true)
    while HasModelLoaded(vehicle) do
        Wait(0)
        local plyCoords = GetEntityCoords(PlayerPedId())
        local x,y,z = -1168.2845458984,-897.15124511719,13.921936988831
        local distance = GetDistanceBetweenCoords(plyCoords.x,plyCoords.y,plyCoords.z,x,y,z,false)
        
        if ok == false then
            if distance <= 3 then
                DrawText3D(-1168.2845458984,-897.15124511719,13.921936988831, '~g~E~s~ - Take Orders')
                if IsControlJustPressed(0,38) and not IsEntityPlayingAnim(myPed, "mini@repair", "fixing_a_player", 3) then
                    loadAnimDict("mini@repair")
                    TaskPlayAnim(myPed, "mini@repair", 'fixing_a_ped', 100.0, 1.0, -1, 1, 0, 0, 0, 0)
                    local finished = exports["r5m-taskbar"]:taskBar(10000,"Taking Orders") 
                    if finished == 100 then
                        ClearPedTasks(PlayerPedId())
                        if Config.Inv == "np" then
                           TriggerEvent('player:receiveItem', item , count)
                        elseif Config.Inv == "qb" then
                            TriggerServerEvent("merty:esyaekle", item, count)   
                        end    
                        ok = true
                        
                        TaskVehicleDriveToCoord(ped, GetVehiclePedIsIn(ped, false), -1134.6663818359,-932.58044433594,2.6060316562653, 4.0, 1.0, GetHashKey(GetEntityModel(GetVehiclePedIsIn(ped, false))), 1074528293, 17.0, false)
                        SetPedKeepTask(ped, true)
                        local x2,y2,z2 = -1134.6663818359,-932.58044433594,2.6060316562653
                        local pedCoords = GetEntityCoords(ped)
                        local peddistance = GetDistanceBetweenCoords(pedCoords.x,pedCoords.y,pedCoords.z,x2,y2,z2,false)
                        if peddistance <= 3 then
                            DeleteCar(spawned_car)
                        end
                        
                    end
                end
            end
        end

    end
end)