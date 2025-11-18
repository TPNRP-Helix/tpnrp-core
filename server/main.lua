---/********************************/
---/*            Main              */
---/********************************/
TPNRPServer = TPNRPServer.new()

function onShutdown()
    DAO.DB.Close()
end

-- Exports for other resources
exports('tpnrp-core', 'getCore', function()
    return TPNRPServer
end)