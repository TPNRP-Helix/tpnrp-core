---/********************************/
---/*            Main              */
---/********************************/
TPNRPServer = TPNRPServer.new()

function onShutdown()
    -- Shutdown server
    TPNRPServer:onShutdown()
end

-- Exports for other resources
exports('tpnrp-core', 'getCore', function()
    return TPNRPServer
end)