---@type table<string, TMissionData>
SHARED.missions = {
    newbie_1 = {
        id = 'newbie_1',
        title = {
            en = 'Buy Bread and Water',
            vi = 'Mua Bánh và Nước'
        },
        description = {
            en = 'Buy 10 bread and 10 water from the closest store. Bread and water are two essential items for survival.',
            vi = 'Mua 10 bánh và 10 nước từ cửa hàng gần nhất. Bánh mì và nước là 2 nhu yếu phẩm thiết yếu để sinh tồn.'
        },
        rewardSuccessMessage = {
            en = 'Thank you for helping me with these essential items. Here is your reward!',
            vi = 'Cảm ơn bạn đã mua giúp tôi những nhu yếu phẩm này. Đây là phần thưởng của bạn!'
        },
        requirements = {
            {
                type = 'buy',
                name = 'bread',
                amount = 10
            },
            {
                type = 'buy',
                name = 'water',
                amount = 10
            },
            {
                type = 'npc_take_item',
                name = 'bread',
                amount = 5
            },
            {
                type = 'npc_take_item',
                name = 'water',
                amount = 5
            }
        },
        requireToTakeMission = {
            level = 1,
        },
        rewards = {
            {
                type = 'cash',
                amount = 30 -- $
            },
            {
                type = 'item',
                name = 'bread',
                amount = 5
            },
            {
                type = 'item',
                name = 'water',
                amount = 5
            }
        }
    }
}