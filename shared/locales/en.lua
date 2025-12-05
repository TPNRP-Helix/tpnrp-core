local en = {
    core = {
        unknown_key = "Unknown translation: {key}",
    },
    inventory = {
        full = "Inventory is full ({current}/{limit}).",
        added = "Item added to inventory.",
        removed = "Removed {count}x {item} from inventory.",
        pickUp = "Pick up",
        open = "Open",
        canAddItem = "Item can be add to inventory.",
        openDrop = "Open Drop",
        pickUpItem = "Pick up",
        itemNotFound = "Item not found!",
        itemReceived = "You have received x{count} {item} from {player}!",
        itemGiven = "You have given x{count} {item} to {player}!",
    },
    backpack = {
        full = 'Backpack is full!'
    },
    player = {
        created = "Player created successfully.",
        loaded = "Player loaded.",
        saved = "Player saved.",
    },
    equipment = {
        equipped = "Equipped",
        unequipped = "Unequipped",
        slot_occupied = "Slot is already occupied.",
    },
    error = {
        createCharacter = {
            failedToCreateCharacter = "Failed to create character!",
        },
        failedToGetLicense = "Failed to get license. Contact admin for support.",
        joinGameFailed = "Failed to join game",
        joinGame = {
            playerNotFound = "Player not found!",
        },
        failedToGetPlayer = "Failed to get player!",
        invalidData = "Invalid data!",
        deleteCharacter = {
            failedToDeleteCharacter = "Failed to delete character!",
        },
        noEmptySlotAvailable = "No empty slot available!",
        itemNotCloth = "Item is not a cloth item!",
        inventoryWeightLimitReached = "Inventory weight limit reached!",
        inventoryFull = "Inventory is full!",
        playerNotFound = "Player not found!",
        targetPlayerNotFound = "Target player not found!",
        itemCannotBeUsed = "Item cannot be used",
        cannotAddItemsToPlayerWeightLimitReached = "Cannot add items to player! Weight limit reached!",
        cannotAddItemsToPlayerSlotLimitReached = "Cannot add items to player! Slot limit reached!",
    },
    success = {
        joinGame = "Joined game successfully",
        createCharacter = "Character created successfully!",
        deleteCharacter = "Character deleted successfully!",
    },
    npc = {
        citizen_identification_officer = 'Citizen Identification Officer',
    },
    mission = {
        notFound = 'Mission not found!',
        notMetRequirements = 'Player does not meet mission requirements!',
        taken = 'Mission taken successfully!',
    }
}

return en
