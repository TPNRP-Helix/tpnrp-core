---@class Vector3
---@field X number
---@field Y number
---@field Z number

---@class Quaternion
---@field Yaw number

---/********************************/
---/*          HELIX Class         */
---/********************************/

---@class LyraPlayerState
---@field GetHelixUserId fun(): string
---@field GetPlayerName fun(): string
---@field GetPlayerId fun(): number

---@class PlayerController
---@field GetLyraPlayerState fun(): LyraPlayerState

---@class WebUI
---@field SendEvent fun(self: WebUI, event: string, ...: any): nil
---@field Destroy fun(self: WebUI): nil
---@field RegisterEventHandler fun(self: WebUI, event: string, callback: function): nil
---@field SetInputMode fun(self: WebUI, mode: EWebUIInputMode): nil
---@field BringToFront fun(self: WebUI): nil

---/********************************/
---/*          TPN's Class         */
---/********************************/

---@class TNotification
---@field title string notification title
---@field message? string notification message
---@field type? 'success' | 'error' | 'warning' | 'info' notification type
---@field duration? number notification duration

---@class TLogCheatParams
---@field action string action name
---@field content string content of log
---@field license string License of player
---@field citizenId? string CitizenId of player
---@field player? SPlayer Player entity
---@field name? string player name