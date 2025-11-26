---@type table<string, TWorldItem>
SHARED.dropItems = {
    -- Cards
    id_card = { path = "/Game/QBCore/Meshes/SM_Clipboard.SM_Clipboard", scale = Vector(0.8, 0.8, 0.8) },
    driver_license = { path = "/Game/QBCore/Meshes/SM_Clipboard.SM_Clipboard", scale = Vector(0.8, 0.8, 0.8) },
}

---Get item path by item name
---@param itemName string
---@return TWorldItem worldItem
SHARED.getWorldItemPath = function(itemName)
    local item = SHARED.dropItems[itemName:lower()]
    if item then
        return item
    end
    -- Fallback to default path
    return {
        path = "/Game/QBCore/Meshes/SM_DuffelBag.SM_DuffelBag",
        scale = Vector(0.8, 0.8, 0.8),
    }
end