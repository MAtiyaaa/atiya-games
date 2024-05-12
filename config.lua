Config = {}

-- Commands
Config.RollCommandName = 'roll'
Config.ShopRollCommandName = 'shoproll'
Config.RPSCommandName = 'rps'
Config.RPSAcceptCommandName = 'rpsaccept'
Config.RPSDeclineCommandName = 'rpsdecline'

Config.Commands = {
    [Config.RollCommandName] = {
        description = 'Rolls a random number between 1 and the max number',
        parameters = {
            { name = 'Max Number', help = 'Enter the maximum number' }
        }
    },
    [Config.ShopRollCommandName] = {
        description = 'Rolls a random number between 1 and the max number with the objective of hitting a winning number',
        parameters = {
            { name = 'Max Number', help = 'Enter the maximum number' },
            { name = 'Winning Number', help = 'Enter the winning number' }
        }
    },
    [Config.RPSCommandName] = {
        description = 'Challenge another player to a game of Rock Paper Scissors.',
        parameters = {
            { name = 'Player ID', help = 'Enter the ID of the player you want to challenge.' }
        }
    },
    [Config.RPSAcceptCommandName] = {
        description = 'Accept a Rock Paper Scissors challenge.',
        parameters = {}
    },
    
    [Config.RPSDeclineCommandName] = {
        description = 'Decline a Rock Paper Scissors challenge.',
        parameters = {}
    },
}

Config.MaxRollNumber = 9999  -- Maximum number that can be rolled

-- Roll Command Settings
Config.RollEnabled = true
Config.RollDisabledMessage = 'The roll command is currently disabled.'

-- Shop Roll Settings
Config.ShopRollShuffle = {
    ShuffleDuration = 3000, -- Duration of the shuffling numbers in milliseconds
    ShuffleInterval = 300, -- Time between each shuffle number update in milliseconds
}
Config.TextDisplayDurationAfterShuffle = 7000 -- In milliseconds, 7000 = 7.0 seconds
Config.ShopRollEnabled = true
Config.ShopRollAllAccess = true  -- If false, only the people with the allowed jobs below can access it
Config.WinningColor = { r = 0, g = 255, b = 0, a = 255 }
Config.WinningEmojis = {'🎉', '🎊'}
Config.ShopRollDisabledMessage = 'The shop roll command is currently disabled.'
Config.ShopRollNoPermissionMessage = 'You do not have permission to use the shop roll command.'
Config.ShopRollAllowedJobs = { -- Useless if Config.ShopRollAllAccess is true
    ['beanmachine'] = true,
    ['catcafe'] = true,
}

Config.RollColor = { r = 255, g = 255, b = 255, a = 255 } -- Color of the text
Config.TextOffset = { x = 0.0, y = 0.0, z = 1.0 }
Config.RollDistance = 10  -- Distance for the 3D text
Config.TextDisplayDuration = 5000 -- In milliseconds, 5000 = 5.0 seconds

Config.RollAnimation = { dict = "mp_player_intwank", name = "mp_player_int_wank" } -- Get animations from https://alexguirre.github.io/animations-list/
Config.AnimationDuration = 2500 -- In milliseconds, 2500 = 2.5 seconds


