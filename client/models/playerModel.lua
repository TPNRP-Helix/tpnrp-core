MODEL.player = {}

MODEL.player.getCharacters = function(callback)
    TriggerCallback('TPN:player:callback:getCharacters', function(characters)
        callback(characters)
    end)
end