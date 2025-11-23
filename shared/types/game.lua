---@class Vector3
---@field x number
---@field y number
---@field z number

---@class Quaternion
---@field Yaw number

---@class Rotator
---@field Pitch number
---@field Yaw number
---@field Roll number

---/********************************/
---/*          HELIX Class         */
---/********************************/

---@class LyraPlayerState
---@field GetHelixUserId fun(): string
---@field GetPlayerName fun(): string
---@field GetPlayerId fun(): number

---@class PlayerController
---@field GetLyraPlayerState fun(): LyraPlayerState
---@field Kick fun(self: PlayerController, reason: string): nil

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

---@class TSpawnStaticMeshParams
---@field entityPath string Path to entity (Ex: /Game/QBCore/Meshes/SM_DuffelBag.SM_DuffelBag)
---@field position Vector3 position to spawn
---@field scale Vector3 Scale of mesh
---@field rotation Rotator Rotation of mesh
---@field collisionType ECollisionType Collision type of mesh
---@field mobilityType EMobilityType Mobility type of mesh

---@alias TInteractAction fun(actor: unknown, instigator: PlayerController)

---@class TInteractableOption
---@field text string Display text for this option
---@field subText string Sub text for this option
---@field input string InputAction? (TODO: MORE DOCUMENTATION NEEDED!) Ex: '/Game/Input/Actions/IA_Interact.IA_Interact'
---@field action TInteractAction callback function when player click
---@field ability string|nil (TODO: MORE DOCUMENTATION NEEDED!)

---@class TAddInteractableParams
---@field entityId string Entity id
---@field entity unknown Entity (TODO: MORE DOCUMENTATION NEEDED!)
---@field options TInteractableOption[] List of option

---@class TEntity Manage by sGame
---@field id string Entity id
---@field entity unknown Entity (TODO: MORE DOCUMENTATION NEEDED!)
---@field interactableEntity unknown Entity (TODO: MORE DOCUMENTATION NEEDED!)
---@field isInteractable boolean Is this entity interactable