

---@class CWebUI
---@field private _core TPNRPClient core entity
---@field private _webUI WebUI webUI entity
CWebUI = {}
CWebUI.__index = CWebUI

---@return CWebUI
function CWebUI.new(core)
    ---@class CWebUI
    local self = setmetatable({}, CWebUI)

    self._core = core
    self._webUI = nil

    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        self._webUI = WebUI('tpnrp-core', 'tpnrp-core/client/tpnrp-ui/dist/index.html', 0)
    end


    ---/********************************/
    ---/*          Functions           */
    ---/********************************/
    
    ---Destroy webUI entity
    function self:destroy()
        if not self._webUI then return end
        self._webUI.Destroy()
        self._webUI = nil
    end

    ---Send event to webUI
    ---@param event string event name
    ---@vararg any event data
    function self:sendEvent(event, ...)
        if not self._webUI then
            print('[ERROR] CWebUI.SEND_EVENT - webUI is not initialized!')
            return false
        end
        -- TODO: Implement a cheat detection system for sending events
        -- All event that is not sent by authorized packages should be dropped
        self._webUI.SendEvent(event, ...)
        print('[INFO] CWebUI.SEND_EVENT - event sent to webUI!')
        return true
    end

    ---Register event handler
    ---@param event string event name
    ---@param callback function event callback
    function self:registerEventHandler(event, callback)
        if not self._webUI then
            print('[ERROR] CWebUI.REGISTER_EVENT_HANDLER - webUI is not initialized!')
            return false
        end
        -- TODO: Implement a cheat detection system for event handlers
        -- All event handlers that are not registered by authorized packages should be dropped
        self._webUI.RegisterEventHandler(event, callback)
        print('[INFO] CWebUI.REGISTER_EVENT_HANDLER - event handler registered!')
        return true
    end

    _contructor()
    ---- END ----
    return self
end

return CWebUI
