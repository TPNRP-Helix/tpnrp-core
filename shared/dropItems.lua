---@type table<string, TWorldItem>
SHARED.dropItems = {
    -- Cards
    id_card = { path = "/Game/QBCore/Meshes/SM_Clipboard.SM_Clipboard", scale = Vector(0.8, 0.8, 0.8), rotation = 90 },
    driver_license = { path = "/Game/QBCore/Meshes/SM_Clipboard.SM_Clipboard", scale = Vector(0.8, 0.8, 0.8), rotation = 90 },
    cloth_bag_item_1 = { path = "/Game/QBCore/Meshes/SM_DuffelBag.SM_DuffelBag", scale = Vector(0.8, 0.8, 0.8), rotation = 90 },
}

---Get item path by item name
---@param itemName string
---@return TWorldItem worldItem
SHARED.getWorldItemPath = function(itemName)
    local defaultItem = {
        path = "/Game/QBCore/Meshes/SM_Trash.SM_Trash",
        scale = Vector(0.5, 0.5, 0.5),
        rotation = 90,
    }
    if not itemName or itemName == '' then
        return defaultItem
    end
    local item = SHARED.dropItems[itemName:lower()]
    if item then
        return item
    end
    -- Fallback to default path
    return defaultItem
end