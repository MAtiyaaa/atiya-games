local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('atiya-roll:diceRollResult')
AddEventHandler('atiya-roll:diceRollResult', function(rollResult, maxNumber)
    local playerPed = PlayerPedId()
    if not IsEntityPlayingAnim(playerPed, Config.RollAnimation.dict, Config.RollAnimation.name, 3) then
        loadAnimDict(Config.RollAnimation.dict)
        TaskPlayAnim(playerPed, Config.RollAnimation.dict, Config.RollAnimation.name, 8.0, -8, -1, 49, 0, false, false, false)
        Citizen.SetTimeout(Config.AnimationDuration, function()
            ClearPedTasks(playerPed)
        end)
    end
    local offset = vector3(Config.TextOffset.x, Config.TextOffset.y, Config.TextOffset.z)
    local text = string.format("%d/%d", rollResult, maxNumber)
    TriggerServerEvent('atiya-roll:diceRollResult', rollResult, maxNumber)
    StartDisplayingText(text, offset, Config.RollColor, Config.TextDisplayDuration, playerPed)
end)

RegisterNetEvent('atiya-roll:shopDiceRollResult')
AddEventHandler('atiya-roll:shopDiceRollResult', function(rollResult, maxNumber, isWinner, winningEmojis)
    local playerPed = PlayerPedId()
    local offset = vector3(Config.TextOffset.x, Config.TextOffset.y, Config.TextOffset.z)
    local finalColor = isWinner and Config.WinningColor or Config.RollColor
    local shuffleColor = Config.RollColor
    TriggerServerEvent('atiya-roll:shopDiceRollResult', rollResult, maxNumber, isWinner, winningEmojis)
end)

RegisterNetEvent('atiya-roll:startShuffle')
AddEventHandler('atiya-roll:startShuffle', function(targetPlayer, maxNumber)
    local playerPed = GetPlayerPed(GetPlayerFromServerId(targetPlayer))
    if not IsEntityPlayingAnim(playerPed, Config.RollAnimation.dict, Config.RollAnimation.name, 3) then
        loadAnimDict(Config.RollAnimation.dict)
        TaskPlayAnim(playerPed, Config.RollAnimation.dict, Config.RollAnimation.name, 8.0, -8, -1, 49, 0, false, false, false)
        Citizen.SetTimeout(Config.AnimationDuration, function()
            ClearPedTasks(playerPed)
        end)
    end
    local endTime = GetGameTimer() + Config.ShopRollShuffle.ShuffleDuration
    while GetGameTimer() < endTime do
        local fakeRollResult = math.random(1, maxNumber)
        local text = string.format("%d/%d", fakeRollResult, maxNumber)
        local offset = vector3(Config.TextOffset.x, Config.TextOffset.y, Config.TextOffset.z)
        StartDisplayingText(text, offset, Config.RollColor, Config.ShopRollShuffle.ShuffleInterval, playerPed)
        Citizen.Wait(Config.ShopRollShuffle.ShuffleInterval)
    end
end)

RegisterNetEvent('atiya-roll:displayPlayer3DText')
AddEventHandler('atiya-roll:displayPlayer3DText', function(targetPlayer, rollResult, maxNumber)
    local text = string.format("%d/%d", rollResult, maxNumber)
    local playerPed = GetPlayerPed(GetPlayerFromServerId(targetPlayer))
    local offset = vector3(Config.TextOffset.x, Config.TextOffset.y, Config.TextOffset.z)
    local color = Config.RollColor
    local duration = Config.TextDisplayDuration

    StartDisplayingText(text, offset, color, duration, playerPed)
end)

RegisterNetEvent('atiya-roll:displayPlayer3DText2')
AddEventHandler('atiya-roll:displayPlayer3DText2', function(targetPlayer, text, color, duration)
    local playerPed = GetPlayerPed(GetPlayerFromServerId(targetPlayer))
    local offset = vector3(Config.TextOffset.x, Config.TextOffset.y, Config.TextOffset.z)
    StartDisplayingText(text, offset, color, duration, playerPed)
end)


function StartDisplayingText(text, offset, color, duration, playerPed)
    local endTime = GetGameTimer() + duration
    Citizen.CreateThread(function()
        while GetGameTimer() < endTime do
            local playerCoords = GetEntityCoords(playerPed) + offset
            Draw3DText(playerCoords.x, playerCoords.y, playerCoords.z, text, color)
            Citizen.Wait(0)
        end
    end)
end

function Draw3DText(x, y, z, text, color)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(color.r, color.g, color.b, color.a)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end
