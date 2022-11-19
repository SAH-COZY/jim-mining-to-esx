RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

------------------------------------------------------------
--Selling animations are simply a pass item to seller animation
RegisterNetEvent('jim-mining:SellAnim', function(data)
	if not HasItem(data.item, 1) then triggerNotify(nil, Loc[Config.Lan].error["dont_have"].." "..QBCore.Shared.Items[data.item].label, "error") return end
	loadAnimDict("mp_common")
	TriggerServerEvent('jim-mining:Selling', data) -- Had to slip in the sell command during the animation command
	loadAnimDict("mp_common")
	lookEnt(data.ped)
	TaskPlayAnim(PlayerPedId(), "mp_common", "givetake2_a", 100.0, 200.0, 0.3, 1, 0.2, 0, 0, 0)	--Start animations
	TaskPlayAnim(data.ped, "mp_common", "givetake2_b", 100.0, 200.0, 0.3, 1, 0.2, 0, 0, 0)
	Wait(2000)
	StopAnimTask(PlayerPedId(), "mp_common", "givetake2_a", 1.0)
	StopAnimTask(data.ped, "mp_common", "givetake2_b", 1.0)
	unloadAnimDict("mp_common")
	if data.sub then TriggerEvent('jim-mining:JewelSell:Sub', { sub = data.sub, ped = data.ped }) return
	else TriggerEvent('jim-mining:SellOre', data) return end
end)

------------------------------------------------------------

RegisterNetEvent('jim-mining:CraftMenu', function(data)
	-- local CraftMenu = {}
	-- if data.ret then
	-- 	CraftMenu[#CraftMenu + 1] = { header = Loc[Config.Lan].info["craft_bench"], txt = Loc[Config.Lan].info["req_drill_bit"], isMenuHeader = true }
	-- 	CraftMenu[#CraftMenu + 1] = { icon = "fas fa-circle-arrow-left", header = "", txt = Loc[Config.Lan].info["return"], params = { event = "jim-mining:JewelCut" } }
	-- else
	-- 	CraftMenu[#CraftMenu + 1] = { header = Loc[Config.Lan].info["smelter"], txt = Loc[Config.Lan].info["smelt_ores"], isMenuHeader = true }
	-- 	CraftMenu[#CraftMenu + 1] = { icon = "fas fa-circle-xmark", header = "", txt = Loc[Config.Lan].info["close"], params = { event = "jim-mining:CraftMenu:Close" } }
	-- end
	-- 	for i = 1, #data.craftable do
	-- 		for k in pairs(data.craftable[i]) do
	-- 			if k ~= "amount" then
	-- 				local text = ""
	-- 				if data.craftable[i]["amount"] then amount = " x"..data.craftable[i]["amount"] else amount = "" end
	-- 				setheader = "<img src=nui://"..Config.img..QBCore.Shared.Items[k].image.." width=30px onerror='this.onerror=null; this.remove();'>"..QBCore.Shared.Items[k].label..tostring(amount)
	-- 				local disable = false
	-- 				local checktable = {}
	-- 				for l, b in pairs(data.craftable[i][tostring(k)]) do
	-- 					if b == 1 then number = "" else number = " x"..b end
	-- 					text = text.."- "..QBCore.Shared.Items[l].label..number.."<br>"
	-- 					settext = text
	-- 					checktable[l] = HasItem(l, b)
	-- 				end
	-- 				for _, v in pairs(checktable) do if v == false then disable = true break end end
	-- 				if not disable then setheader = setheader.." ✔️" end
	-- 				CraftMenu[#CraftMenu + 1] = { isMenuHeader = disable, icon = k, header = setheader, txt = settext, params = { event = "jim-mining:MakeItem", args = { item = k, tablenumber = i, craftable = data.craftable, ret = data.ret } } }
	-- 				settext, amount, setheader = nil
	-- 			end
	-- 		end
	-- 	end
	-- exports['qb-menu']:openMenu(CraftMenu)
	Menu.OpenCraftMenu()
end)

RegisterNetEvent('jim-mining:SellOre', function(data)
	Menu.OpenSellOreMenu()
	-- local list = {"goldingot", "silveringot", "copperore", "ironore", "goldore", "silverore", "carbon"}
	-- local sellMenu = {
	-- 	{ header = Loc[Config.Lan].info["header_oresell"], txt = Loc[Config.Lan].info["oresell_txt"], isMenuHeader = true },
	-- 	{ icon = "fas fa-circle-xmark", header = "", txt = Loc[Config.Lan].info["close"], params = { event = "jim-mining:CraftMenu:Close" } } }
	-- for _, v in pairs(list) do
	-- 	local setheader = "<img src=nui://"..Config.img..QBCore.Shared.Items[v].image.." width=30px onerror='this.onerror=null; this.remove();'>"..QBCore.Shared.Items[v].label
	-- 	local disable = true
	-- 	if HasItem(v, 1) then setheader = setheader.." 💰" disable = false end
	-- 		sellMenu[#sellMenu+1] = { icon = v, disabled = disable, header = setheader, txt = Loc[Config.Lan].info["sell_all"].." "..Config.SellItems[v].." "..Loc[Config.Lan].info["sell_each"], params = { event = "jim-mining:SellAnim", args = { item = v, ped = data.ped } } }
	-- 	Wait(0)
	-- end
	-- exports['qb-menu']:openMenu(sellMenu)
end)
------------------------

RegisterNetEvent('jim-mining:JewelSell', function(data)
	Menu.OpenSellJewelMenu()
end)
--Jewel Selling - Sub Menu Controller
RegisterNetEvent('jim-mining:JewelSell:Sub', function(data)
	Menu.OpenSellVangelicoMenu()
	-- local list = {}
	-- local sellMenu = {
	-- 	{ header = Loc[Config.Lan].info["jewel_buyer"], txt = Loc[Config.Lan].info["sell_jewel"], isMenuHeader = true },
	-- 	{ icon = "fas fa-circle-arrow-left", header = "", txt = Loc[Config.Lan].info["return"], params = { event = "jim-mining:JewelSell", args = data } }, }
	-- if data.sub == "emerald" then list = {"emerald", "uncut_emerald"} end
	-- if data.sub == "ruby" then list = {"ruby", "uncut_ruby"} end
	-- if data.sub == "diamond" then list = {"diamond", "uncut_diamond"} end
	-- if data.sub == "sapphire" then list = {"sapphire", "uncut_sapphire"} end
	-- if data.sub == "rings" then list = {"gold_ring", "silver_ring", "diamond_ring", "emerald_ring", "ruby_ring", "sapphire_ring", "diamond_ring_silver", "emerald_ring_silver", "ruby_ring_silver", "sapphire_ring_silver"} end
	-- if data.sub == "necklaces" then list = {"goldchain", "silverchain", "diamond_necklace", "emerald_necklace", "ruby_necklace", "sapphire_necklace", "diamond_necklace_silver", "emerald_necklace_silver", "ruby_necklace_silver", "sapphire_necklace_silver"} end
	-- if data.sub == "earrings" then list = {"goldearring", "silverearring", "diamond_earring", "emerald_earring", "ruby_earring", "sapphire_earring", "diamond_earring_silver", "emerald_earring_silver", "ruby_earring_silver", "sapphire_earring_silver"} end
	-- for _, v in pairs(list) do
	-- 	local disable = true
	-- 	local setheader = "<img src=nui://"..Config.img..QBCore.Shared.Items[v].image.." width=30px onerror='this.onerror=null; this.remove();'>"..QBCore.Shared.Items[v].label
	-- 	if HasItem(v, 1) then setheader = setheader.." 💰" disable = false end
	-- 	sellMenu[#sellMenu+1] = { disabled = disable, icon = v, header = setheader, txt = Loc[Config.Lan].info["sell_all"].." "..Config.SellItems[v].." "..Loc[Config.Lan].info["sell_each"], params = { event = "jim-mining:SellAnim", args = { item = v, sub = data.sub, ped = data.ped } } }
	-- 	Wait(0)
	-- end
	-- exports['qb-menu']:openMenu(sellMenu)
end)

--Cutting Jewels
RegisterNetEvent('jim-mining:JewelCut', function()
	Menu.OpenCraftMenu()
    -- exports['qb-menu']:openMenu({
	-- 	{ header = Loc[Config.Lan].info["craft_bench"], txt = Loc[Config.Lan].info["req_drill_bit"], isMenuHeader = true },
	-- 	{ icon = "fas fa-circle-xmark", header = "", txt = Loc[Config.Lan].info["close"], params = { event = "jim-mining:CraftMenu:Close" } },
	-- 	{ header = Loc[Config.Lan].info["gem_cut"],	txt = Loc[Config.Lan].info["gem_cut_section"], params = { event = "jim-mining:CraftMenu", args = { craftable = Crafting.GemCut, ret = true  } } },
	-- 	{ header = Loc[Config.Lan].info["make_ring"], txt = Loc[Config.Lan].info["ring_craft_section"], params = { event = "jim-mining:CraftMenu", args = { craftable = Crafting.RingCut, ret = true  } } },
	-- 	{ header = Loc[Config.Lan].info["make_neck"], txt = Loc[Config.Lan].info["neck_craft_section"], params = { event = "jim-mining:CraftMenu", args = { craftable = Crafting.NeckCut, ret = true } } },
	-- 	{ header = Loc[Config.Lan].info["make_ear"], txt = Loc[Config.Lan].info["ear_craft_section"], params = { event = "jim-mining:CraftMenu", args = { craftable = Crafting.EarCut, ret = true } } },
	-- })
end)