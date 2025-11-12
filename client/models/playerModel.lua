MODEL.player = {}

--- Join game
---@param citizenId string player citizen id
---@param callback function callback function
MODEL.player.joinGame = function(citizenId, callback)
    TriggerCallback('callbackOnPlayerJoinGame', function(result)
        callback(result)
    end, citizenId)
end