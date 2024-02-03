local QBCore = exports['qb-core']:GetCoreObject()

local function handleRollCommand(source, args, commandName)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    
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

        if Config.ShopRollAllAccess or Config.ShopRollAllowedJobs[xPlayer.PlayerData.job.name] then
            local winningNumber = tonumber(args[2])
            local rollResult = math.random(1, maxNumber)
            local isWinner = rollResult == winningNumber
            TriggerClientEvent('atiya-roll:shopDiceRollResult', source, rollResult, maxNumber, isWinner, Config.WinningEmojis)
        else
            TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', Config.ShopRollNoPermissionMessage } })
        end
    end
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
