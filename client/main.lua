TPNRPUI = WebUI('TPNRP-UI', 'tpnrp-core/client/tpnrp-ui/dist/index.html', 0)

---/********************************/
---/*            Main              */
---/********************************/
TPNRPClient = TPNRPClient.new()

-- Exports for other resources
exports('tpnrp-core', 'getCore', function()
    return TPNRPClient
end)