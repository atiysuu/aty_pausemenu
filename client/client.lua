local Framework = Config.Framework == "qb" and exports['qb-core']:GetCoreObject() or exports['es_extended']:getSharedObject()
local open = false
local cam

RegisterNUICallback("loaded", function(_, cb)
    cb(Config.Tabs)
end)

RegisterNUICallback("event", function(eType)
    if eType == "close" then
        TriggerServerEvent("aty_pausemenu:dropPlayer")
    elseif eType == "settings" then
        ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_LANDING_MENU'),1,-1) 
        SetNuiFocus(false, false)
    elseif eType == "map" then
        ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_MP_PAUSE'),1,-1) 
        SetNuiFocus(false, false)
    elseif eType == "resume" then
        SetNuiFocus(false, false)
    end

    local playerPed = PlayerPedId()
    open = false
    FreezeEntityPosition(playerPed, false)
    DestroyCam(cam, false)
    DisplayRadar(true)
    RenderScriptCams(false, false, 0, false, false)
end)

RegisterCommand('OpenPauseMenu', function()
    if GetCurrentFrontendMenuVersion() == -1 and not IsNuiFocused() then
        open = true
        OpenPauseMenu()
    end
end)

RegisterKeyMapping('OpenPauseMenu', 'Open Pause Menu', 'keyboard', 'ESCAPE')

CreateThread(function()
    while true do 
        if open then
            SetPauseMenuActive(false)
        end

        Wait(1)
    end
end)

function triggerServerCallback(...)
	if Config.Framework == "qb" then
		Framework.Functions.TriggerCallback(...)
	else
		Framework.TriggerServerCallback(...)
	end
end

function OpenPauseMenu()
    triggerServerCallback("aty_pausemenu:getPlayerData", function(cb)
        SetNuiFocus(true, true)

        SendNUIMessage({
            action = "setData",
            id = cb?.id,
            players = cb?.players,
            maxPlayers = cb?.maxPlayers,
            bank = cb?.bank,
            wallet = cb?.wallet,
            name = cb?.name,
            gender = cb?.gender,
            job = cb?.job,
            grade = cb?.grade,
        })

        local ped = PlayerPedId()
        local coords = GetOffsetFromEntityInWorldCoords(ped, 0, 1.1, 0)
        FreezeEntityPosition(ped, true)
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(cam, false)
        FreezePedCameraRotation(ped)

        if not DoesCamExist(cam) then
            DisplayRadar(false)
            cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
            SetCamActive(cam, true)
            RenderScriptCams(true, false, 0, true, true)
            SetCamUseShallowDofMode(cam, true)
            SetCamNearDof(cam, 0)
            SetCamFarDof(cam, 1.3)
            SetCamDofStrength(cam, 0.1)
            SetPedCanPlayAmbientAnims(ped, true)
        end

        if not IsPedInAnyVehicle(ped, false) then 
            SetCamCoord(cam, coords.x, coords.y, coords.z + 0.6)
            SetCamRot(cam, 0.0, 0.0, GetEntityHeading(ped) + 180)

            while DoesCamExist(cam) do
                SetUseHiDof()
                Wait(0)
            end
        end
    end)
end