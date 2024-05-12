local QBCore = exports['qb-core']:GetCoreObject()

local playerMoves = {}
local currentChallenges = {}

QBCore.Commands.Add(Config.RPSCommandName, Config.Commands[Config.RPSCommandName].description, Config.Commands[Config.RPSCommandName].parameters, true, function(source, args)
    local targetId = tonumber(args[1])
    if targetId then
        local sourcePed = GetPlayerPed(source)
        local targetPed = GetPlayerPed(targetId)
        local sourcePlayer = QBCore.Functions.GetPlayer(source)
        local targetPlayer = QBCore.Functions.GetPlayer(targetId)
        if sourcePed and targetPed then
            local sourceCoords = GetEntityCoords(sourcePed)
            local targetCoords = GetEntityCoords(targetPed)
            if #(sourceCoords - targetCoords) <= 10.0 then
                currentChallenges[targetId] = source
                local sourceName = sourcePlayer.PlayerData.charinfo.firstname .. " " .. sourcePlayer.PlayerData.charinfo.lastname
                local targetName = targetPlayer.PlayerData.charinfo.firstname .. " " .. targetPlayer.PlayerData.charinfo.lastname
                TriggerClientEvent('atiya-rps:invite', targetId, source, sourceName)
            else
                TriggerClientEvent('QBCore:Notify', source, "Player is too far away!", "error")
            end
        else
            TriggerClientEvent('QBCore:Notify', source, "Invalid player ID!", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "Invalid player ID!", "error")
    end
end)

QBCore.Commands.Add(Config.RPSAcceptCommandName, Config.Commands[Config.RPSAcceptCommandName].description, Config.Commands[Config.RPSAcceptCommandName].parameters, true, function(source, args)
    local challengerId = currentChallenges[source]
    if challengerId then
        currentChallenges[source] = nil
        playerMoves[source] = false
        playerMoves[challengerId] = false
        local challengerName = QBCore.Functions.GetPlayer(challengerId).PlayerData.charinfo.firstname .. " " .. QBCore.Functions.GetPlayer(challengerId).PlayerData.charinfo.lastname
        local targetName = QBCore.Functions.GetPlayer(source).PlayerData.charinfo.firstname .. " " .. QBCore.Functions.GetPlayer(source).PlayerData.charinfo.lastname
        TriggerClientEvent('atiya-rps:startGame', source, challengerId, challengerName, targetName)
        TriggerClientEvent('atiya-rps:startGame', challengerId, source, targetName, challengerName)
    else
        TriggerClientEvent('QBCore:Notify', source, "No active challenge to accept!", "error")
    end
end)

QBCore.Commands.Add(Config.RPSDeclineCommandName, Config.Commands[Config.RPSDeclineCommandName].description, Config.Commands[Config.RPSDeclineCommandName].parameters, true, function(source, args)
    local challengerId = currentChallenges[source]
    if challengerId then
        currentChallenges[source] = nil
        TriggerClientEvent('QBCore:Notify', challengerId, "Your challenge was declined.", "error")
    end
    TriggerClientEvent('QBCore:Notify', source, "Challenge declined.", "primary")
end)

function BroadcastMove(playerId, move)
    local playerPed = GetPlayerPed(playerId)
    local coords = GetEntityCoords(playerPed)
    TriggerClientEvent('atiya-rps:displayMoveText', -1, playerId, coords, move)
end

RegisterNetEvent('atiya-rps:makeMove', function(move, playerId, opponentId)
    playerMoves[playerId] = move
    if playerMoves[opponentId] then
        BroadcastMove(playerId, move)
        BroadcastMove(opponentId, playerMoves[opponentId])
        resolveGame(playerId, opponentId)
    end
end)

function resolveGame(player1, player2)
    local player1Data = QBCore.Functions.GetPlayer(player1)
    local player2Data = QBCore.Functions.GetPlayer(player2)
    local move1 = playerMoves[player1]
    local move2 = playerMoves[player2]
    playerMoves[player1] = nil
    playerMoves[player2] = nil
    local result
    local winner
    if not player1Data or not player2Data then
        print("Failed to retrieve player data in resolveGame.")
        return
    end
    local player1Name = player1Data.PlayerData.charinfo.firstname .. " " .. player1Data.PlayerData.charinfo.lastname
    local player2Name = player2Data.PlayerData.charinfo.firstname .. " " .. player2Data.PlayerData.charinfo.lastname
    if move1 == move2 then
        result = "It's a tie!"
        winner = "No one"
    elseif (move1 == 'r' and move2 == 's') or (move1 == 'p' and move2 == 'r') or (move1 == 's' and move2 == 'p') then
        result = "Player " .. player1Name .. " wins!"
        winner = "Player " .. player1Name .. " (" .. player1 .. ")"
    else
        result = "Player " .. player2Name .. " wins!"
        winner = "Player " .. player2Name .. " (" .. player2 .. ")"
    end
    TriggerClientEvent('atiya-rps:startAnimation', player1)
    TriggerClientEvent('atiya-rps:startAnimation', player2)
    Citizen.SetTimeout(4000, function()
        TriggerClientEvent('atiya-rps:showResult', player1, move1, move2, result, winner)
        TriggerClientEvent('atiya-rps:showResult', player2, move1, move2, result, winner)
    end)
end