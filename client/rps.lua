local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('atiya-rps:invite', function(challengerId, challengerName)
    TriggerEvent('QBCore:Notify', "Player " .. challengerName .. " has challenged you to Rock, Paper, Scissors. Use /rpsaccept to accept.", "primary")
end)

RegisterNetEvent('atiya-rps:startGame', function(opponentId, opponentName, playerName)
    exports['qb-menu']:openMenu({
        {
            header = "Rock, Paper, Scissors - " .. playerName .. " vs " .. opponentName,
            isMenuHeader = true,
        },
        {
            header = "Rock",
            txt = "Choose Rock",
            params = {
                event = "atiya-rps:makeMove",
                args = {
                    move = 'r',
                    playerId = GetPlayerServerId(PlayerId()),
                    opponentId = opponentId
                }
            }
        },
        {
            header = "Paper",
            txt = "Choose Paper",
            params = {
                event = "atiya-rps:makeMove",
                args = {
                    move = 'p',
                    playerId = GetPlayerServerId(PlayerId()),
                    opponentId = opponentId
                }
            }
        },
        {
            header = "Scissors",
            txt = "Choose Scissors",
            params = {
                event = "atiya-rps:makeMove",
                args = {
                    move = 's',
                    playerId = GetPlayerServerId(PlayerId()),
                    opponentId = opponentId
                }
            }
        }
    })
end)

RegisterNetEvent('atiya-rps:startAnimation', function(move1, move2)
    local playerPed = PlayerPedId()
    local dict = "mp_player_intwank"
    local name = "mp_player_int_wank"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
    TaskPlayAnim(playerPed, dict, name, 8.0, -8.0, -1, 0, 0, false, false, false)
end)

RegisterNetEvent('atiya-rps:makeMove', function(data)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    if coords and coords.x and coords.y and coords.z then
        TriggerServerEvent('atiya-rps:makeMove', data.move, data.playerId, data.opponentId)
    else
        print("Invalid coords")
    end
end)

RegisterNetEvent('atiya-rps:showResult', function(move1, move2, result, winner)
    TriggerEvent('QBCore:Notify', result .. " (" .. winner .. ")", "primary")
end)

RegisterNetEvent('atiya-rps:displayMoveText', function(playerId, playerCoords, move)
    local localPlayerId = GetPlayerServerId(PlayerId())
    if #(GetEntityCoords(PlayerPedId()) - playerCoords) <= 10 then
        local moves = {r = "🪨", p = "📄", s = "✂️"}
        local moveSequence = {moves["r"], moves["p"], moves["s"], "🔫", moves[move]}
        local displayDurations = {250, 250, 250, 250, 2000}
        Citizen.CreateThread(function()
            for i, text in ipairs(moveSequence) do
                Display3DTextAboveHead(playerCoords, text, displayDurations[i])
                Wait(displayDurations[i])
            end
        end)
    end
end)

function Display3DTextAboveHead(coords, text, duration)
    local endTime = GetGameTimer() + duration
    while GetGameTimer() <= endTime do
        Wait(0)
        local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z + 0.5)
        if onScreen then
            SetTextScale(0.35, 0.35)
            SetTextFont(4)
            SetTextProportional(1)
            SetTextColour(255, 255, 255, 215)
            SetTextEntry("STRING")
            SetTextCentre(1)
            AddTextComponentString(text)
            DrawText(x, y)
        end
    end
end