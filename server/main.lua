/********************************/
/*            Main              */
/********************************/
TPNRPServer = TPNRPServer.new()

-- Exports for other resources
exports('core', function()
    return TPNRPServer
end)