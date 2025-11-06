TPNRPUI = WebUI('tpnrp-core', 'tpnrp-core/client/tpnrp-ui/dist/index.html', 0)

---/********************************/
---/*            Main              */
---/********************************/
TPNRPClient = TPNRPClient.new()

-- Exports for other resources
exports('tpnrp-core', 'getCore', function()
    return TPNRPClient
end)

function onShutdown()
    if TPNRPUI then
        TPNRPUI:Destroy()
        TPNRPUI = nil
    end
end