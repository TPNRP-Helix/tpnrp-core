local vi = {
    core = {
        unknown_key = "Thiếu bản dịch: {key}",
    },
    inventory = {
        full = "Túi đã đầy!",
        added = "Đã thêm vật phẩm vào túi.",
        removed = "Đã bỏ {count}x {item} khỏi túi.",
        pickUp = "Nhặt",
        open = "Mở",
        canAddItem = "Vật phẩm có thể được thêm vào túi.",
        openDrop = "Mở",
        itemNotFound = "Không tìm thấy vật phẩm!",
    },
    backpack = {
        full = 'Túi đồ đã đầy!',
    },
    player = {
        created = "Tạo nhân vật thành công.",
        loaded = "Đã tải nhân vật.",
        saved = "Đã lưu nhân vật.",
    },
    equipment = {
        equipped = "Đã trang bị {item}.",
        unequipped = "Đã tháo {item}.",
        slot_occupied = "Ô trang bị đã được sử dụng.",
    },
    error = {
        createCharacter = {
            failedToCreateCharacter = "Không thể tạo nhân vật!",
        },
        failedToGetLicense = "Không tìm thấy license. Liên hệ admin để được hỗ trợ.",
        joinGameFailed = "Không thể vào game",
        joinGame = {
            playerNotFound = "Không tìm thấy nhân vật!",
        },
        failedToGetPlayer = "Không tìm thấy nhân vật!",
        invalidData = "Dữ liệu không hợp lệ!",
        deleteCharacter = {
            failedToDeleteCharacter = "Không thể xóa nhân vật!",
        },
        noEmptySlotAvailable = "Không có ô trống trong túi đồ!",
        itemNotCloth = "Vật phẩm không phải là quần áo!",
        inventoryWeightLimitReached = "Túi đồ đã đầy trọng lượng!",
        inventoryFull = "Túi đồ đã đầy!",
        playerNotFound = "Không tìm thấy nhân vật!",
        itemCannotBeUsed = "Vật phẩm không thể sử dụng!",
    },
    success = {
        joinGame = "Đã vào game thành công",
        createCharacter = "Tạo nhân vật thành công!",
        deleteCharacter = "Xóa nhân vật thành công!",
    },
    npc = {
        citizen_identification_officer = 'Trưởng phòng công dân',
    },
    mission = {
        notFound = 'Không tìm thấy nhiệm vụ!',
        notMetRequirements = 'Bạn không đủ điều kiện để nhận nhiệm vụ này!',
        taken = 'Bạn đã nhận nhiệm vụ thành công!',
    }
}

return vi
