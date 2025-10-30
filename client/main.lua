/********************************/
/*            Main              */
/********************************/
TPNRPClient = TPNRPClient.new()

-- Exports for other resources
exports('tpnrp-core', function()
    return TPNRPClient
end)