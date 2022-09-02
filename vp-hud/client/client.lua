PlayerData = {}
isLoggedIn, inVehicle, driverSeat, Show, phoneOpen = false, false, false, false, false
playerPed, vehicle, vehicleClass, Fuel, vehicleClass = 0, 0, 0, 0, 0 

local QBCore = exports['qb-core']:GetCoreObject()

local bigMap = false
local onMap = false
local cashAmount = 0
local bankAmount = 0

Citizen.CreateThread(function()
    while true do
        playerPed = PlayerPedId()
        inVehicle = false
        if IsPedInAnyVehicle(playerPed, false)  then
            vehicle = GetVehiclePedIsIn(playerPed, false)
            vehicleClass = GetVehicleClass(vehicle)
            inVehicle = not IsVehicleModel(vehicle, `wheelchair`) and vehicleClass ~= 13 and not IsVehicleModel(vehicle, `windsurf`)
            vehicleClass = GetVehicleClass(vehicle)
            driverSeat = GetPedInVehicleSeat(vehicle, -1) == playerPed
            Fuel = GetVehicleFuelLevel(vehicle)
        end
        SendNUIMessage({
            type = 'tick',
            heal = (GetEntityHealth(playerPed)-100),
            zirh = GetPedArmour(playerPed),
            stamina = 100 - GetPlayerSprintStaminaRemaining(PlayerId()),
            oxy = IsPedSwimmingUnderWater(playerPed) and GetPlayerUnderwaterTimeRemaining(PlayerId()) or 100,
            vehicle = inVehicle,
            phoneOpen = phoneOpen
        })
        Citizen.Wait(200)
    end
end)




local miniMapUi = false
function UIStuff()
    Citizen.CreateThread(function()
        while Show do
            Citizen.Wait(0)
            if inVehicle and not onMap then
                DisplayRadar(1)
                SetPedConfigFlag(playerPed, 35, false)
                onMap = true
            elseif not inVehicle and onMap then
                onMap = true
                DisplayRadar(0)
                
            end

            BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
            ScaleformMovieMethodAddParamInt(3)
            EndScaleformMovieMethod()

            if IsPauseMenuActive() then
                if miniMapUi then
                    SendNUIMessage({type = "ui", show = false})
                    miniMapUi = false
                    DisplayRadar(0)
                    
                end
            elseif not IsPauseMenuActive() then
                if not miniMapUi then
                    SendNUIMessage({type = "ui", show = true})
                    miniMapUi = true
                    DisplayRadar(0)
                   
                end
            end
        end
        onMap = false
    end)
end
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerEvent('vp-hud:open-hud')
end)
print("[vp-hud] Hud hakkında destek almak için discord.gg/vipe adresinden bize ulaşabilirsiniz.")


RegisterCommand('hud', function()
    TriggerEvent('vp-hud:open-hud')
end)

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
AddEventHandler("hud:client:UpdateNeeds") -- reka:hud:sendStatus
    SendNUIMessage({
        type = "updateStatus",
        data = {
            yemek = newHunger,
            su = newThirst,
        },
    })
end)


function circleMap()
    RequestStreamedTextureDict("circlemap", false)
    while not HasStreamedTextureDictLoaded("circlemap") do
        Wait(100)
    end

    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")

    SetMinimapClipType(1)
    SetMinimapComponentPosition("minimap", "L", "B", 0.025, -0.03, 0.153, 0.30)
    SetMinimapComponentPosition("minimap_mask", "L", "B", 0.135, 0.12, 0.093, 0.164)
    SetMinimapComponentPosition("minimap_blur", "L", "B", 0.012, 0.022, 0.256, 0.337)
    SetBlipAlpha(GetNorthRadarBlip(), 0)

    minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Citizen.Wait(100)
    SetRadarBigmapEnabled(false, false)
end

RegisterNetEvent('SaltyChat_VoiceRangeChanged')
AddEventHandler('SaltyChat_VoiceRangeChanged', function(seviye)
    if seviye == 2.0 then
        SendNUIMessage({type = 'voice', lvl = "1"})
    elseif seviye == 7.0 then
        SendNUIMessage({type = 'voice', lvl = "2"})
    elseif seviye == 15.0 then
        SendNUIMessage({type = 'voice', lvl = "3"})
    end
end)

local normalKonusmaAktif = false
RegisterNetEvent('SaltyChat_TalkStateChanged')
AddEventHandler('SaltyChat_TalkStateChanged', function(status)
    if status and not normalKonusmaAktif then
        normalKonusmaAktif = true
        SendNUIMessage({type = 'speak', active = true})
    elseif not status and normalKonusmaAktif then
        normalKonusmaAktif = false
        SendNUIMessage({type = 'speak', active = false})
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    TriggerEvent("hud:client:SetMoney")
    SendNUIMessage({action = 'showui'})
    UIStuff()
    isLoggedIn = true
    Show = true
    Citizen.Wait(10000)
end)

function firstLogin()
    PlayerData = QBCore.Functions.GetPlayerData()
    TriggerEvent("hud:client:SetMoney")
    UIStuff()
    isLoggedIn = true
    Show = true
    TriggerEvent("tgian-hud:load-data")
end

RegisterNetEvent('vp-hud:ui')
AddEventHandler('vp-hud:ui', function(open)
    if open then 
        UIStuff()
        Show = true
        SendNUIMessage({action = 'showui'})
    else
        Show = false
        SendNUIMessage({action = 'hideui'})
        Citizen.Wait(500)
        DisplayRadar(0)
    end
end)

RegisterNetEvent('esx:playerUnloaded')
AddEventHandler('esx:playerUnloaded', function()
    SendNUIMessage({action = 'hideui'})
    isLoggedIn = false
    Show = false
end)

RegisterNetEvent('vp-hud:open-hud')
AddEventHandler('vp-hud:open-hud', function()
    if not Show then
        PlayerData = QBCore.Functions.GetPlayerData()
        TriggerEvent("tgian-hud:load-data")
        SendNUIMessage({action = 'ui'})
        UIStuff()
        isLoggedIn = true
        Show = true
    end
end)
RegisterNetEvent('vp-hud:open-hud1')
AddEventHandler('vp-hud:open-hud1', function()
    if not Show then
        PlayerData = QBCore.Functions.GetPlayerData()
        TriggerEvent("tgian-hud:load-data")
        SendNUIMessage({action = 'showui'})
        UIStuff()
        isLoggedIn = true
        Show = true
    end
end)



RegisterNUICallback('close-ayar-menu', function()
    SetNuiFocus(false, false)
end)

local disSes = false
Citizen.CreateThread(function()
    RegisterKeyMapping('+radiooSpeaker', 'Telsiz Hoparlör Modu', 'keyboard', 'F5')
end)

RegisterCommand("+radioSpeaker", function()
    disSes = not disSes
    TriggerServerEvent("ls-radio:set-disses", disSes)
    SendNUIMessage({action = 'disSes', disSes = disSes})
end, false)

RegisterNUICallback('set-emotechat', function(data)
    TriggerEvent("3dme-chat", data.status)
end)

RegisterNetEvent('vp-hud:parasut')
AddEventHandler('vp-hud:parasut', function()
	GiveWeaponToPed(playerPed, `gadget_parachute`, 1, false, false)
	SetPedComponentVariation(playerPed, 5, 8, 3, 0)
end)

RegisterNetEvent('phone:open')
AddEventHandler('phone:open', function(bool)
    phoneOpen = bool
    print(phoneOpen)
    if not phoneOpen then Citizen.Wait(500) end
    SendNUIMessage({type = 'phone', phoneOpen = phoneOpen})
end)

RegisterNetEvent('hud:client:ShowAccounts', function(type, amount)
    if type == 'cash' then
        SendNUIMessage({
            action = 'show',
            type = 'cash',
            cash = amount
        })
    else
        SendNUIMessage({
            action = 'show',
            type = 'bank',
            bank = amount
        })
    end
end)

RegisterNetEvent('hud:client:OnMoneyChange', function(type, amount, isMinus)
    cashAmount = PlayerData.money['cash']
    bankAmount = PlayerData.money['bank']
    SendNUIMessage({
        action = 'updatemoney',
        cash = cashAmount,
        bank = bankAmount,
        amount = amount,
        minus = isMinus,
        type = type
    })
end)



--Açlık, Susuzluk İndirme Döngüsü
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        Citizen.Wait(msec)
        if isLoggedIn then
            TriggerServerEvent("QBCore:Server:SetMetaData", "hunger", QBCore.Functions.GetPlayerData().metadata["hunger"] - 1)
            TriggerServerEvent("QBCore:Server:SetMetaData", "thirst", QBCore.Functions.GetPlayerData().metadata["thirst"] - 1)
            local hunger = QBCore.Functions.GetPlayerData().metadata["hunger"]
            local thirst = QBCore.Functions.GetPlayerData().metadata["thirst"]
  
        end
  	end
end)


--Açlık susuzluk çekme
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if isLoggedIn then
        local xPlayer = QBCore.Functions.GetPlayerData()
        TriggerServerEvent("QBCore:Server:SetMetaData", "hunger", QBCore.Functions.GetPlayerData().metadata["hunger"])
        TriggerServerEvent("QBCore:Server:SetMetaData", "thirst", QBCore.Functions.GetPlayerData().metadata["thirst"])
        end
    end
end)

Citizen.CreateThread(function()
    while true do  
        Citizen.Wait(1000)
    local playeramkk = PlayerPedId()
    local araba = GetVehiclePedIsIn(playeramkk)
    SetPlaneTurbulenceMultiplier(araba, 0)
    end
end)
