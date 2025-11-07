---/********************************/
---/*            Main              */
---/********************************/
TPNRPClient = TPNRPClient.new()

function onShutdown() TPNRPClient:onShutdown() end

-- Exports for other resources
exports('tpnrp-core', 'getCore', function()
    return TPNRPClient
end)
