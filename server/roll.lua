local QBCore = exports['qb-core']:GetCoreObject()

local function handleRollCommand(source, args, commandName)
    local Player = QBCore.Functions.GetPlayer(source)
    local maxNumber = tonumber(args[1]) or 100
    if maxNumber > Config.MaxRollNumber then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'The maximum roll number is ' .. Config.MaxRollNumber .. '.' } })
        return
    end
    if commandName == Config.RollCommandName then
        if not Config.RollEnabled then
            TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', Config.RollDisabledMessage } })
            return
        end
        if Config.RollEnabled then
            local rollResult = math.random(1, maxNumber)
            TriggerClientEvent('atiya-roll:diceRollResult', source, rollResult, maxNumber)
        end
    elseif commandName == Config.ShopRollCommandName then
        if not Config.ShopRollEnabled then
            TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', Config.ShopRollDisabledMessage } })
            return
        end
        if Config.ShopRollAllAccess or Config.ShopRollAllowedJobs[Player.PlayerData.job.name] then
            local winningNumber = tonumber(args[2])
            local rollResult = math.random(1, maxNumber)
            local isWinner = rollResult == winningNumber
            TriggerClientEvent('atiya-roll:shopDiceRollResult', source, rollResult, maxNumber, isWinner, Config.WinningEmojis)
        else
            TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', Config.ShopRollNoPermissionMessage } })
        end
    end
end

RegisterNetEvent('atiya-roll:diceRollResult')
AddEventHandler('atiya-roll:diceRollResult', function(rollResult, maxNumber)
    local src = source
    local playerPed = GetPlayerPed(src)
    local nearbyPlayers = GetPlayersWithinRadius(GetEntityCoords(playerPed), 50)

    for _, playerID in ipairs(nearbyPlayers) do
        TriggerClientEvent('atiya-roll:displayPlayer3DText', playerID, src, rollResult, maxNumber)
    end
end)

RegisterNetEvent('atiya-roll:shopDiceRollResult')
AddEventHandler('atiya-roll:shopDiceRollResult', function(rollResult, maxNumber, isWinner, winningEmojis)
    local src = source
    local playerPed = GetPlayerPed(src)
    local coords = GetEntityCoords(playerPed)
    local nearbyPlayers = GetPlayersWithinRadius(coords, 50)


    for _, playerID in ipairs(nearbyPlayers) do
        TriggerClientEvent('atiya-roll:startShuffle', playerID, src, maxNumber)
    end
    SetTimeout(Config.ShopRollShuffle.ShuffleDuration, function()
        local finalText = isWinner and string.format("%s %d/%d %s", winningEmojis[1], rollResult, maxNumber, winningEmojis[2]) or string.format("%d/%d", rollResult, maxNumber)
        for _, playerID in ipairs(nearbyPlayers) do
            TriggerClientEvent('atiya-roll:displayPlayer3DText2', playerID, src, finalText, isWinner and Config.WinningColor or Config.RollColor, Config.TextDisplayDurationAfterShuffle)
        end
    end)
end)

function GetPlayersWithinRadius(coords, radius)
    local players = GetPlayers()
    local filteredPlayers = {}
    for _, player in ipairs(players) do
        local ped = GetPlayerPed(player)
        if #(GetEntityCoords(ped) - coords) < radius then
            table.insert(filteredPlayers, player)
        end
    end
    return filteredPlayers
end

QBCore.Commands.Add(Config.RollCommandName, Config.Commands[Config.RollCommandName].description, Config.Commands[Config.RollCommandName].parameters, true, function(source, args)
    handleRollCommand(source, args, Config.RollCommandName)
end)

QBCore.Commands.Add(Config.ShopRollCommandName, Config.Commands[Config.ShopRollCommandName].description, Config.Commands[Config.ShopRollCommandName].parameters, true, function(source, args)
    handleRollCommand(source, args, Config.ShopRollCommandName)
end)


RegisterNetEvent('atiya-roll:handleRoll')
AddEventHandler('atiya-roll:handleRoll', function(commandName, args)
    handleRollCommand(source, args, commandName)
end)
