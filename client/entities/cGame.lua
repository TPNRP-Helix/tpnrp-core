---@class CGame
---@field core TPNRPClient core entity
CGame = {}
CGame.__index = CGame

---/********************************/
---/*        [Server] Core         */
---/********************************/

--- Creates a new instance of CGame.
---@return CGame
function CGame.new(core)
    ---@class CGame
    local self = setmetatable({}, CGame)
    
    self.core = core

    ---Contructor function
    local function _contructor()
        
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/

    ---Play animation
    ---@param pawn HPawn|nil pawn actor
    ---@param animationName string animation name
    ---@param options table<string, any> options
    function self:playAnimation(pawn, animationName, options)
        local loopCount = options.loopCount or 1
        local bIgnoreMovementInput = options.bIgnoreMovementInput or true
        -- Get pawn
        local char = pawn or self.core.player:getPawn()
        if not char then
            return false
        end
        -- Create animation params
        local AnimParams = UE.FHelixPlayAnimParams()
        AnimParams.LoopCount = loopCount
        AnimParams.bIgnoreMovementInput = bIgnoreMovementInput
        -- Play animation
        Animation.Play(char, animationName, AnimParams, function()
            if not options.onEnd then
                return
            end
            -- Callback on end animation
            options.onEnd()
        end)

        return true
    end

    _contructor()
    return self
end

return CGame