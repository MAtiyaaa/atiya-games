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
    StartDisplayingText(text, offset, Config.RollColor, Config.TextDisplayDuration, playerPed)
end)

RegisterNetEvent('atiya-roll:shopDiceRollResult')
AddEventHandler('atiya-roll:shopDiceRollResult', function(rollResult, maxNumber, isWinner, winningEmojis)
    local playerPed = PlayerPedId()

    if not IsEntityPlayingAnim(playerPed, Config.RollAnimation.dict, Config.RollAnimation.name, 3) then
        loadAnimDict(Config.RollAnimation.dict)
        TaskPlayAnim(playerPed, Config.RollAnimation.dict, Config.RollAnimation.name, 8.0, -8, -1, 49, 0, false, false, false)
        
        Citizen.SetTimeout(Config.AnimationDuration, function()
            ClearPedTasks(playerPed)
        end)
    end

    local offset = vector3(Config.TextOffset.x, Config.TextOffset.y, Config.TextOffset.z)
    local finalColor = isWinner and Config.WinningColor or Config.RegularRollColor
    local shuffleColor = Config.RollColor

    if Config.ShopRollShuffle.Enabled then
        local endTime = GetGameTimer() + Config.ShopRollShuffle.ShuffleDuration
        while GetGameTimer() < endTime do
            local fakeRollResult = math.random(1, maxNumber)
            local text = string.format("%d/%d", fakeRollResult, maxNumber)
            StartDisplayingText(text, offset, shuffleColor, Config.ShopRollShuffle.ShuffleInterval, playerPed)
            Citizen.Wait(Config.ShopRollShuffle.ShuffleInterval)
        end
        local finalText = isWinner and string.format("%s %d/%d %s", winningEmojis[1], rollResult, maxNumber, winningEmojis[2]) or string.format("%d/%d", rollResult, maxNumber)
        StartDisplayingText(finalText, offset, finalColor, Config.TextDisplayDurationAfterShuffle, playerPed)
    else
    StartDisplayingText(text, offset, color, Config.TextDisplayDuration, playerPed)
    end
end)

RegisterNetEvent('atiya-roll:requestRollInput')
AddEventHandler('atiya-roll:requestRollInput', function(itemName, commandName)
    if Config.ItemCommandMapping[itemName] == Config.RollCommandName then
        QBCore.Functions.Prompt('Enter roll amount (Max: ' .. Config.MaxRollNumber .. '):', '', 10, function(input)
            local rollNumber = tonumber(input)
            if rollNumber and rollNumber > 0 and rollNumber <= Config.MaxRollNumber then
                TriggerServerEvent('atiya-roll:handleRoll', commandName, { rollNumber })
            else
                QBCore.Functions.Notify('Invalid number, roll cancelled.', 'error')
            end
        end)
    elseif Config.ItemCommandMapping[itemName] == Config.ShopRollCommandName then
        QBCore.Functions.Prompt('Enter roll amount (Max: ' .. Config.MaxRollNumber .. '):', '', 10, function(inputMax)
            local maxNumber = tonumber(inputMax)
            if not (maxNumber and maxNumber > 0 and maxNumber <= Config.MaxRollNumber) then
                QBCore.Functions.Notify('Invalid number, roll cancelled.', 'error')
                return
            end
            QBCore.Functions.Prompt('Enter target number (Max: ' .. maxNumber .. '):', '', 10, function(inputTarget)
                local targetNumber = tonumber(inputTarget)
                if targetNumber and targetNumber > 0 and targetNumber <= maxNumber then
                    TriggerServerEvent('atiya-roll:handleRoll', commandName, { maxNumber, targetNumber })
                else
                    QBCore.Functions.Notify('Invalid target number, roll cancelled.', 'error')
                end
            end)
        end)
    end
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

RegisterNetEvent('atiya-roll:display3DText')
AddEventHandler('atiya-roll:display3DText', function(text, coords, color, duration)
    StartDisplayingText(text, coords, color, duration)
end)

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
