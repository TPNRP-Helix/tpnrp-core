---@class SCharacterManager
---@field core TPNRPServer Core
SCharacterManager = {}
SCharacterManager.__index = SCharacterManager

---@param core TPNRPServer Core
---@return SCharacterManager
function SCharacterManager.new(core)
    ---@class SCharacterManager
    local self = setmetatable({}, SCharacterManager)

    -- Core
    self.core = core

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
         
        -- Create character
        ---@param source PlayerController player controller
        ---@param data table data
        ---@return table result
        RegisterCallback('createCharacter', function(source, data)
            return self:onCreateCharacter(source, data)
        end)
        
        -- Delete character
        ---@param source PlayerController player controller
        ---@param citizenId string citizen id
        ---@return table result
        RegisterCallback('deleteCharacter', function(source, citizenId)
            return self:onDeleteCharacter(source, citizenId)
        end)

        -- On Player join game
        ---@param source PlayerController player controller
        ---@param citizenId string citizen id
        ---@return table result
        RegisterCallback('callbackOnPlayerJoinGame', function(source, citizenId)
            return self:onPlayerJoinGame(source, citizenId)
        end)
    end

    ---/********************************/
    ---/*          Functions           */
    ---/********************************/

    ---On create character
    ---@param source PlayerController player controller
    ---@param data table data
    ---@return {status: boolean; message: string; playerData: table|nil} result
    function self:onCreateCharacter(source, data)
        local license = self.core:getLicenseBySource(source)
        if not license then
            print('[ERROR] TPNRPServer.bindCallbackEvents - Failed to get license by source!')
            return {
                status = false,
                message = SHARED.t('error.failedToGetLicense'),
                playerData = nil
            }
        end
        local playerData = {
            citizenId = SHARED.createCitizenId(),
            license = license,
            name = data.firstName .. ' ' .. data.lastName,
            money = SHARED.DEFAULT.PLAYER.money,
            characterInfo = {
                firstName = data.firstName,
                lastName = data.lastName,
                gender = data.gender,
                birthday = data.dateOfBirth,
            },
            job = SHARED.DEFAULT.PLAYER.job,
            gang = SHARED.DEFAULT.PLAYER.gang,
            position = SHARED.DEFAULT.SPAWN.POSITION,
            heading = SHARED.DEFAULT.SPAWN.HEADING,
            metadata = SHARED.DEFAULT.PLAYER.metadata,
            level = SHARED.DEFAULT.LEVEL,
        }
        -- Create character
        local result = DAO.player.createCharacter(license, playerData)
        if not result then
            print(('[ERROR] TPNRPServer.bindCallbackEvents - Failed to create character for %s (License: %s)'):format(playerData.name, license))
            return {
                status = false,
                message = SHARED.t('error.createCharacter.failedToCreateCharacter'),
                playerData = nil
            }
        end
        -- Return success
        return {
            status = true,
            message = SHARED.t('success.createCharacter'),
            playerData = playerData,
        }
    end

    ---On delete character
    ---@param source PlayerController player controller
    ---@param citizenId string citizen id
    ---@return {status: boolean; message: string} result
    function self:onDeleteCharacter(source, citizenId)
        local license = self.core:getLicenseBySource(source)
        if not license then
            print('[ERROR] TPNRPServer.bindCallbackEvents - Failed to get license by source!')
            return {
                status = false,
                message = SHARED.t('error.failedToGetLicense'),
            }
        end
        local result = DAO.player.deleteCharacter(license, citizenId)
        if not result then
            print('[ERROR] TPNRPServer.bindCallbackEvents - Failed to delete character!')
            return {
                status = false,
                message = SHARED.t('error.deleteCharacter.failedToDeleteCharacter'),
            }
        end
        return {
            status = true,
            message = SHARED.t('success.deleteCharacter'),
        }
    end

    ---On player join game
    ---@param source PlayerController player controller
    ---@param citizenId string citizen id
    ---@return {status: boolean; message: string; playerData: table|nil} result
    function self:onPlayerJoinGame(source, citizenId)
        local license = self.core:getLicenseBySource(source)
        if not license then
            print('[ERROR] TPNRPServer.bindCallbackEvents - Failed to get license by source!')
            return {
                status = false,
                message = SHARED.t('error.failedToGetLicense'),
                playerData = nil
            }
        end
        local playerData = DAO.player.get(citizenId)
        if playerData.license ~= license then
            print('[ERROR] TPNRPServer.bindCallbackEvents - Player license mismatch!')
            -- TODO: Cheat detect!!
            -- TODO: Consider to ban this player by diconnected and add to blacklist
            self.core.cheatDetector:logCheater({
                action = 'joinGame',
                citizenId = citizenId,
                license = license,
                content = ('[ERROR] TPNRPServer.bindCallbackEvents - Player license mismatch!')
            })
            -- This player trying to login with character of other player
            return {
                status = false,
                message = SHARED.t('error.joinGame.playerNotFound'),
                playerData = nil
            }
        end
        -- Create player
        local player = SPlayer.new(self.core, source, playerData)
        -- Assign back playerData with other properties
        playerData = player:login()
        -- Push player into array
        self.core.players[#self.core.players + 1] = player

        -- Return success
        return {
            status = true,
            message = SHARED.t('success.joinGame'),
            playerData = playerData,
        }
    end

    _contructor()
    ---- END ----
    return self
end

return SCharacterManager
