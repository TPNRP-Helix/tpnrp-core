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
---@field SendEvent fun(event: string, ...: any): nil
---@field Destroy fun(): nil
---@field RegisterEventHandler fun(event: string, callback: function): nil