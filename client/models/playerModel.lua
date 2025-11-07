MODEL.player = {}

---Get characters of this player
---@param callback function callback function
MODEL.player.getCharacters = function(callback)
    ---@param characters { maxCharacters: number, characters: table<number, PlayerData> } data characters of this player
    TriggerCallback('TPN:player:callback:getCharacters', function(characters)
        callback(characters)
    end)
end