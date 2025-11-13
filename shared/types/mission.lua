---@alias TMissionActionType 'buy' | 'sell' | 'drop' | 'craft' | 'use' | 'kill_npc' | 'talk_npc' | 'npc_take_item' | 'add_item' | 'remove_item' | 'spend' | 'receive'

---@class TMissionRequirement
---@field type TMissionActionType
---@field name string|nil item name
---@field amount number|nil item amount
---@field info table|nil item custom info
---@field npcName string|nil NPC name 

---@class TMissionProgress : TMissionRequirement
---@field isTalkedToNPC boolean|nil This mean player is talked to NPC or not
---@field currentAmount number|nil current Amount value of item

---@class TMissionReward
---@field type 'item' | 'cash' | 'bank' | 'exp' | 'skill'
---@field name string|nil item name or skill name
---@field amount number|nil item amount or skill amount
---@field info table|nil item custom info or skill custom info
---@field exp number|nil exp that player will receive

---@class TRequireToTakeMission
---@field level number|nil Level require to take this mission
---@field skillName string|nil Skill name require to take this mission
---@field skillLevel number|nil Skill level require to take this mission

---@class TMissionData
---@field id string Short name of mission (Should not contains any special characters)
---@field title {en:string;vi:string} Mission title with locales
---@field description {en:string;vi:string} Mission description with locales
---@field rewardSuccessMessage {en:string;vi:string} After player success mission. This message will be display
---@field requirements TMissionRequirement[] Requirements of mission
---@field requireToTakeMission TRequireToTakeMission Player need to match these requirement before they take mission
---@field rewards TMissionReward[] Rewards of mission
---@field location Vector3|nil location to do this mission
---@field locationRadius number|nil Out of this radius from location meaning mission won't trigger

---@class TMissionEntity
---@field id string Mission id
---@field isActive boolean Is mission active or not
---@field isCompleted boolean Is mission completed or not
---@field progress TMissionProgress[] Progress of requirement