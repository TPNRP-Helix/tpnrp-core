

---@class CWebUI
---@field private _core TPNRPClient core entity
---@field private _webUI WebUI webUI entity
CWebUI = {}
CWebUI.__index = CWebUI

---@return CWebUI
function CWebUI.new(core)
    ---@class CWebUI
    local self = setmetatable({}, CWebUI)

    self.core = core
    self._webUI = nil
    self.isFocusing = false
    -- Log
    self.nucleus = nil
    self.lastLogIndex = 0



    ---/********************************/
    ---/*         Initializes          */
    ---/********************************/

    ---Contructor function
    local function _contructor()
        self._webUI = WebUI('tpnrp-core', 'tpnrp-core/client/tpnrp-ui/dist/index.html', 0)
        self._webUI:BringToFront()
        -- Hide default UI
        self:hideDefaultUI()
        -- Bind game input
        self:bindInput()

        -- [DEV] Bind log tool
        -- self:bindLog()

        ---+-----------------------------------------------+
        -- | Listen event                                  |
        ---+-----------------------------------------------/
   
        -- out focus UI
        self:registerEventHandler('doOutFocus', function()
            self:outFocus()
        end)

        ---+-----------------------------------------------+
        -- | Bind callback                                 |
        ---+-----------------------------------------------/
    end


    ---/********************************/
    ---/*          Functions           */
    ---/********************************/

    function self:bindInput()
        -- [GAME] [F1] Toggle guide helper
        Input.BindKey('F1', function()
            if not self.core:isInGame() then
                return
            end
            self:sendEvent('toggleGuideHelper')
        end, 'Pressed')

        -- [GAME] [F2] Toggle focus with mouse
        Input.BindKey('F2', function()
            if not self.core:isInGame() and self.core.permission ~= 'admin' then
                return
            end
            if self.isFocusing then
                -- Close focus 
                self:outFocus()
                return
            end
            -- Toggle focus mode
            self._webUI:SetInputMode(EWebUIInputMode.UI)
            self.isFocusing = true
        end, 'Pressed')

        -- [GAME] [F3] Toggle toast expand
        Input.BindKey('F3', function()
            if not self.core:isInGame() then
                return
            end
            self:sendEvent('toggleToastExpand')
        end, 'Pressed')

        -- [GAME] [F9] Toggle settings
        Input.BindKey('F9', function()
            if not self.core:isInGame() then
                return
            end
            if self.isFocusing then
                -- Close focus 
                self:outFocus()
                self:sendEvent('toggleSettings')
                return
            end
            self._webUI:SetInputMode(EWebUIInputMode.UI)
            self:sendEvent('toggleSettings')
            self.isFocusing = true
        end, 'Pressed')

        -- [ADMIN] [F7] Dev Mode menu
        Input.BindKey('F7', function()
            TriggerCallback('getPermissions', function(result)
                if result ~= 'admin' then
                    return
                end
                -- Player is admin
                if self.isFocusing then
                    -- Close focus 
                    self:outFocus()
                    self:sendEvent('setDevModeOpen', false)
                    return
                end
                -- Open focus and open dev tools
                self._webUI:SetInputMode(EWebUIInputMode.UI)
                self:sendEvent('setDevModeOpen', true)
                self.isFocusing = true
            end)
        end, 'Pressed')
    end

    ---Hide default UI
    function self:hideDefaultUI()
        SetHUDVisibility({
            Healthbar = false,
            Inventory = false,
            Speedometer = false,
            WeaponState = false,
            Shortcuts = false,
        })
    end

    ---Destroy webUI entity
    function self:destroy()
        if not self._webUI then return end
        self._webUI:Destroy()
        self._webUI = nil
    end

    ---Send event to webUI
    ---@param event string event name
    ---@vararg any event data
    function self:sendEvent(event, ...)
        if not self._webUI then
            return false
        end
        -- TODO: Implement a cheat detection system for sending events
        -- All event that is not sent by authorized packages should be dropped
        self._webUI:SendEvent(event, ...)
        print('[INFO] CWebUI.SEND_EVENT - event \'' .. event .. '\' sent to webUI!')
        return true
    end

    ---Register event handler
    ---@param event string event name
    ---@param callback function event callback
    function self:registerEventHandler(event, callback)
        if not self._webUI then
            return false
        end
        -- TODO: Implement a cheat detection system for event handlers
        -- All event handlers that are not registered by authorized packages should be dropped
        self._webUI:RegisterEventHandler(event, callback)
        print('[INFO] CWebUI.REGISTER_EVENT_HANDLER - event handler registered!')
        return true
    end

    ---Focus webUI
    function self:focus()
        if not self._webUI then
            return false
        end
        self._webUI:SetInputMode(EWebUIInputMode.UI)
        self.isFocusing = true
    end

    ---Out focus from webUI
    function self:outFocus()
        if not self._webUI then
            return false
        end
        self._webUI:SetInputMode(EWebUIInputMode.None)
        self.isFocusing = false
    end

    _contructor()
    ---- END ----
    return self
end

return CWebUI
