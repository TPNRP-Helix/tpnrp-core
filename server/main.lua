---/********************************/
---/*            Main              */
---/********************************/
TPNRPServer = TPNRPServer.new()

-- Exports for other resources
exports('tpnrp-core', 'getCore', function()
    return TPNRPServer
end)