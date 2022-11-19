Menu = {}

function Menu.OpenStoreMenu()
    local main = RageUI.CreateMenu("", "STORE MENU")

    RageUI.Visible(main, true)

    local list = Config.Items

    while main do
        RageUI.IsVisible(main, function()
            for i,v in ipairs(list.items) do
                RageUI.Button(list.items[i].name, nil, {RightLabel = '~g~'..tostring(list.items[i].price)..'$~s~ →'}, true, {
                    onSelected = function()
                        
                    end
                })
            end
        end, function() end)

        if not RageUI.Visible(main) then
            main = RMenu:DeleteType('main')
            
        end
        Wait(1)
    end
end

function Menu.OpenCraftMenu()
    local main = RageUI.CreateMenu("", "CRAFT MENU")

    local main_list = {
        ['gem_cut'] = {
            label = 'Gem Cut',
            menu = RageUI.CreateSubMenu(main, "", "GEM CUT"),
            list = Crafting.GemCut
        },
        ['ring_cut'] = {
            label = 'Ring Cut',
            menu = RageUI.CreateSubMenu(main, "", "RINGS"),
            list = Crafting.RingCut
        },
        ['neck_cut'] = {
            label = 'Neck Cut',
            menu = RageUI.CreateSubMenu(main, "", "NECK"),
            list = Crafting.NeckCut
        },
        ['ear_cut'] = {
            label = 'Ear Cut',
            menu = RageUI.CreateSubMenu(main, "", "EAR"),
            list = Crafting.EarCut
        },
    }

    local function AreAllMenusClose()
        for k,v in pairs(main_list) do
            if RageUI.Visible(v.menu) then
                return false
            end
        end
        return true
    end

    RageUI.Visible(main, true)

    while main do
        RageUI.IsVisible(main, function()
            for k,v in pairs(main_list) do
                RageUI.Button(v.label, nil, {RightLabel = "→"}, true, {}, v.menu)
            end
        end, function() end)

        for k,v in pairs(main_list) do
            RageUI.IsVisible(v.menu, function()
                for i,v2 in ipairs(v.list) do
                    for k3,v3 in pairs(v2) do
                        if k3 ~= "amount" then
                            RageUI.Button(k3, nil, {RightLabel = "Craft →"}, true, {
                                onSelected = function()
                                    TriggerServerEvent('jim-mining:MakeItem', v2) -- REMAKE ACTION OF MAKEITEM AND ADAPT ARGUMENTS TO SEND LESS ARGS AS POSSIBLE
                                end
                            })
                        end
                    end
                end
            end, function() end)
        end

        if not RageUI.Visible(main) and AreAllMenusClose() then
            main = RMenu:DeleteType('main')
            for k,v in pairs(main_list) do
                v.menu = RMenu:DeleteType(v.menu)
            end
        end
        Wait(1)
    end
end

function Menu.OpenSellOreMenu()
    local main = RageUI.CreateMenu("", "SELL MENU")

    RageUI.Visible(main, true)

    local list = {"goldingot", "silveringot", "copperore", "ironore", "goldore", "silverore", "carbon"}

    while main do
        RageUI.IsVisible(main, function()
            for i = 1, #list do
                RageUI.Button(list[i], nil, {RightLabel = '~g~'..Config.SellItems[list[i]]..'$ →'}, true, {
                    onSelected = function()
                        TriggerEvent('jim-mining:SellAnim', list[i])
                    end
                }) -- CHECK ALL OF THAT IF ITS GOOD
            end
        end, function() end)

        if not RageUI.Visible(main) then
            main = RMenu:DeleteType('main')
        end
        Wait(1)
    end
end

function Menu.OpenSellJewelMenu()
    local main = RageUI.CreateMenu("", "SELL MENU")

    RageUI.Visible(main, true)

    local list = {"emerald", "ruby", "diamond", "sapphire", "rings", "necklaces", "earrings"} 

    while main do 
        RageUI.IsVisible(main, function()
            for i = 1, #list do
                RageUI.Button(list[i], nil, {RightLabel = '~g~'..Config.SellItems[list[i]]..'$ →'}, true, {
                    onSelected = function()
                        TriggerServerEvent('jim-mining:JewelSell:Sub', list[i]) -- CHECK ALL OF THAT IF ITS GOOD
                    end
                })
            end
        end, function() end)

        if not RageUI.Visible(main) then
            main = RMenu:DeleteType('main')
            
        end
        Wait(1)
    end
end

function Menu.OpenSellVangelicoMenu()
    local main = RageUI.CreateMenu("", "SELL MENU")

    local main_list = {
        ["emerald"] = {
            menu = RageUI.CreateSubMenu(main, "", "SELL MENU"),
            list = {"emerald", "uncut_emerald"}
        },
        ['ruby'] = {
            menu = RageUI.CreateSubMenu(main, "", "SELL MENU"),
            list = {"ruby", "uncut_ruby"}
        },
        ['diamond'] = {
            menu = RageUI.CreateSubMenu(main, "", "SELL MENU"),
            list = {"diamond", "uncut_diamond"}
        },
        ['sapphire'] = {
            menu = RageUI.CreateSubMenu(main, "", "SELL MENU"),
            list = {"sapphire", "uncut_sapphire"}
        },
        ['rings'] = {
            menu = RageUI.CreateSubMenu(main, "", "SELL MENU"),
            list = {"gold_ring", "silver_ring", "diamond_ring", "emerald_ring", "ruby_ring", "sapphire_ring", "diamond_ring_silver", "emerald_ring_silver", "ruby_ring_silver", "sapphire_ring_silver"}
        },
        ['necklaces'] = {
            menu = RageUI.CreateSubMenu(main, "", "SELL MENU"),
            list = {"goldchain", "silverchain", "diamond_necklace", "emerald_necklace", "ruby_necklace", "sapphire_necklace", "diamond_necklace_silver", "emerald_necklace_silver", "ruby_necklace_silver", "sapphire_necklace_silver"}
        },
        ['earrings'] = {
            menu = RageUI.CreateSubMenu(main, "", "SELL MENU"),
            list = {"goldearring", "silverearring", "diamond_earring", "emerald_earring", "ruby_earring", "sapphire_earring", "diamond_earring_silver", "emerald_earring_silver", "ruby_earring_silver", "sapphire_earring_silver"}
        }
    }

    local function AreAllMenusClose()
        for k,v in pairs(main_list) do
            if RageUI.Visible(v.menu) then
                return false
            end
        end
        return true
    end

    RageUI.Visible(main, true)

    while main do 
        RageUI.IsVisible(main, function()
            for k,v in pairs(main_list) do
                RageUI.Button(k, nil, {RightLabel = "→"}, true, {}, v.menu)
            end
        end, function() end)

        for k,v in pairs(main_list) do
            RageUI.IsVisible(v.menu, function()
                for i,v2 in ipairs(v.list) do
                    RageUI.Button(v2, nil, {RightLabel = 'Sell →'}, true, {
                        onSelected = function()
                            
                        end
                    })
                end
            end, function() end)
        end

        if not RageUI.Visible(main) and AreAllMenusClose() then
            main = RMenu:DeleteType('main')
            for k,v in pairs(main_list) do
                v.menu = RMenu:DeleteType(v.menu)
            end
        end
        Wait(1)
    end
end