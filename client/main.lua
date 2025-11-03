/********************************/
/*            Main              */
/********************************/
TPNRPClient = TPNRPClient.new()

-- Exports for other resources
exports('core', function()
    return TPNRPClient
end)