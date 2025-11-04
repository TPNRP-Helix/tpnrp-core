TPNRPUI = WebUI('TPNRP-UI', 'tpnrp-core/ui/index.html', 0)

/********************************/
/*            Main              */
/********************************/
TPNRPClient = TPNRPClient.new()

-- Exports for other resources
exports('core', function()
    return TPNRPClient
end)