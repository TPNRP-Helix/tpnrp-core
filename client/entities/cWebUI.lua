

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
    self._isFocusing = false
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
        -- Bind log tool
        self:bindLog()

        -- On pressed `F7` to open dev mode
        Input.BindKey('F7', function()
            TriggerCallback('getPermissions', function(result)
                if result ~= 'admin' then
                    return
                end
                -- Player is admin
                if self._isFocusing then
                    -- Close focus 
                    self:outFocus()
                    self:sendEvent('setDevModeOpen', false)
                    return
                end
                -- Open focus and open console
                self._webUI:SetInputMode(EWebUIInputMode.UI)
                self:sendEvent('setDevModeOpen', true)
                self._isFocusing = true
            end)
        end, 'Pressed')

        -- On pressed `F8` to open console
        Input.BindKey('F8', function()
            TriggerCallback('getPermissions', function(result)
                if result ~= 'admin' then
                    return
                end
                -- Player is admin
                if self._isFocusing then
                    -- Close focus and close console
                    self:outFocus()
                    self:sendEvent('setConsoleOpen', false)
                    return
                end
                -- Open focus and open console
                self._webUI:SetInputMode(EWebUIInputMode.UI)
                self:sendEvent('setConsoleOpen', true)
                self._isFocusing = true
            end)
            
        end, 'Pressed')

        -- out focus UI
        self:registerEventHandler('doOutFocus', function()
            self:outFocus()
        end)
        
        -- Get player's permission for WebUI
        TriggerCallback('getPermissions', function(result)
            self:sendEvent('setPermission', result)
        end)
    end


    ---/********************************/
    ---/*          Functions           */
    ---/********************************/
    
    ---Hide default UI
    function self:hideDefaultUI()
        local actors = UE.TArray(UE.AActor)
        UE.UGameplayStatics.GetAllActorsWithTag(HWorld, 'HWebUI', actors)
        if not actors[1] then
            print('[ERROR] CWebUI.HIDE_DEFAULT_UI - HWebUI actor not found')
            return false
        end
        actors[1]:SetHUDVisibility(false, false, true, true, false)
        return true
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
            print('[ERROR] CWebUI.SEND_EVENT - webUI is not initialized!')
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
            print('[ERROR] CWebUI.REGISTER_EVENT_HANDLER - webUI is not initialized!')
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
            print('[ERROR] CWebUI.FOCUS - webUI is not initialized!')
            return false
        end
        self._webUI:SetInputMode(EWebUIInputMode.UI)
        self._isFocusing = true
    end

    ---Out focus from webUI
    function self:outFocus()
        if not self._webUI then
            print('[ERROR] CWebUI.OUT_FOCUS - webUI is not initialized!')
            return false
        end
        self._webUI:SetInputMode(EWebUIInputMode.None)
        self._isFocusing = false
    end

    function self:getActorsWithTag(tag)
        ---@diagnostic disable-next-line: undefined-global
        local actors = UE.TArray(UE.AActor)
        ---@diagnostic disable-next-line: undefined-global
        UE.UGameplayStatics.GetAllActorsWithTag(HWorld, tag, actors)
        return actors[1]
    end
    
    --- [HELIX Team are working on this]
    function self:bindLog()
        Timer.SetInterval(function()
            if not self.nucleus then
                self.nucleus = self:getActorsWithTag("HNucleus")
                if not self.nucleus then
                    print('[HX_CONSOLE] Nucleus actor not found')
                    return
                end
                print('[HX_CONSOLE] Nucleus actor found!')
            end
            
            local logsJson = self.nucleus:GetLocalLogs()
            
            if logsJson and logsJson ~= "" then
                local success, logsData = pcall(function()
                    return JSON.parse(logsJson)
                end)
                
                if success and logsData and logsData.logs then
                    local sentCount = 0
                    for i, logEntry in ipairs(logsData.logs) do
                        if logEntry ~= "" then
                            self:sendEvent('onLogMessage', {
                                message = logEntry,
                                index = self.lastLogIndex + i
                            })
                            sentCount = sentCount + 1
                        end
                    end
                    
                    if #logsData.logs > 0 then
                        self.lastLogIndex = self.lastLogIndex + #logsData.logs
                        if sentCount > 0 then
                            print('[HX_CONSOLE] Sent ' .. sentCount .. ' logs to UI')
                        end
                    end
                else
                    if not success then
                        print('[HX_CONSOLE] Failed to parse JSON: ' .. tostring(logsData))
                    end
                end
            end
        end, 2000)
    end

    _contructor()
    ---- END ----
    return self
end

return CWebUI
