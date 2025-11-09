---/********************************/
---/*            Main              */
---/********************************/
TPNRPServer = TPNRPServer.new()

function onShutdown()
    print('[TPN][SERVER] onShutdown - Close database connection')
    DAO.DB.Close()
end

-- Exports for other resources
exports('tpnrp-core', 'getCore', function()
    return TPNRPServer
end)