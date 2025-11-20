---@type table<string, TMissionData>
SHARED.missions = {
    newbie_0 = {
        id = 'newbie_0',
        assignedNPC = 'citizen_identification_officer',
        title = {
            en = 'Citizen Identification Card',
            vi = 'Căn cước công dân'
        },
        description = {
            en = 'To survive and exist in this city, you need to have an ID card. To get an ID card, you need to go to the nearest police station and register!',
            vi = 'Để sinh sống và tồn tại trong thành phố này bạn cần phải có 1 căn cước công dân. Để lấy căn cước công dân bạn cần đến đồn cảnh sát gần nhất và thực hiện đăng ký!'
        },
        rewardSuccessMessage = {
            en = 'Thank you for registering. Here is your ID card!',
            vi = 'Cảm ơn bạn đã đăng ký. Đây là căn cước công dân của bạn!'
        },
        requirements = {
            {
                type = 'talk_npc',
                npcName = 'citizen_identification_officer',
                name = 'citizen_identification_officer'
            }
        },
        npcDialogs = {
            [1] = {
                id = 1,
                prompt = {
                    en = 'Hello, how can I help you?',
                    vi = 'Xin chào, tôi có thể giúp gì cho bạn?'
                },
                options = {
                    {
                        id = 'ask_for_id',
                        text = {
                            en = 'I am a new citizen. I need to register for an ID card.',
                            vi = 'Tôi là cư dân mới. Tôi cần đăng ký thẻ căn cước.'
                        },
                        isCorrect = true,
                        completesMission = true,
                        nextNode = 2,
                        rewards = {
                            {
                                type = 'item',
                                name = 'id_card',
                                amount = 1
                            }
                        }
                    },
                    {
                        id = 'wrong_answer',
                        text = {
                            en = 'No thanks, I was just passing by.',
                            vi = 'Không cần đâu, tôi chỉ đi ngang qua.'
                        },
                        isCorrect = false,
                        failMessage = {
                            en = 'Please come back when you are ready to register.',
                            vi = 'Hãy quay lại khi bạn sẵn sàng đăng ký nhé.'
                        }
                    }
                }
            },
            [2] = {
                id = 2,
                prompt = {
                    en = 'Here is your citizen ID card. Welcome to the city!',
                    vi = 'Đây là căn cước công dân của bạn. Chào mừng đến thành phố!'
                },
                options = {}
            },
        },
        requireToTakeMission = {
            level = 1,
        },
        rewards = {
            {
                type = 'item',
                name = 'id_card',
                amount = 1
            }
        },
        nextMission = 'newbie_1',
    },
    newbie_1 = {
        id = 'newbie_1',
        assignedNPC = 'citizen_identification_officer',
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
        },
        npcDialogs = {
            [1] = {
                id = 1,
                prompt = {
                    en = 'Can you help restock our supplies? We need bread and bottled water.',
                    vi = 'Bạn có thể giúp bổ sung nhu yếu phẩm không? Chúng tôi cần bánh mì và nước đóng chai.'
                },
                options = {
                    {
                        id = 'confirm_supplies',
                        text = {
                            en = 'I will grab the bread and water you requested.',
                            vi = 'Tôi sẽ mua bánh mì và nước mà anh cần.'
                        },
                        isCorrect = true,
                        nextNode = nil
                    },
                    {
                        id = 'reject_supplies',
                        text = {
                            en = 'I will not help you with that.',
                            vi = 'Tôi sẽ không giúp bạn với điều đó.'
                        },
                        isCorrect = false,
                        failMessage = {
                            en = 'Please come back when you are ready to help us.',
                            vi = 'Hãy quay lại khi bạn sẵn sàng giúp chúng tôi.'
                        }
                    }
                }
            },
            [2] = {
                id = 2,
                prompt = {
                    en = 'Thank you for helping me with these essential items. Here is your reward!',
                    vi = 'Cảm ơn bạn đã mua giúp tôi những nhu yếu phẩm này. Đây là phần thưởng của bạn!'
                },
                options = {}
            }
        },
        nextMission = 'newbie_2',
    }
}