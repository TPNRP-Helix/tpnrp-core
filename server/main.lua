/********************************/
/*            Main              */
/********************************/
TPNRPServer = TPNRPServer.new()

-- Exports for other resources
exports('tpnrp-core', function()
    return TPNRPServer
end)