local DefaultProps = {
	{data = {coords = vector4(-593.29, 2093.22, 131.7, 110.0), prop = `prop_worklight_02a`}, freeze = true, sync = false},-- Mineshaft door
	{data = {coords = vector4(-604.55, 2089.74, 131.15, 300.0), prop = `prop_worklight_02a`}, freeze = true, sync = false}, -- Mineshaft door 2
	{data = {coords = vector4(2991.59, 2758.07, 42.68, 250.85), prop = `prop_worklight_02a`}, freeze = true, sync = false},  -- Quarry Light
	{data = {coords = vector4(2991.11, 2758.02, 42.66, 194.6), prop = `prop_worklight_02a`}, freeze = true, sync = false},  -- Quarry Light
	{data = {coords = vector4(2971.78, 2743.33, 43.29, 258.54), prop = `prop_worklight_02a`}, freeze = true, sync = false},  -- Quarry Light
	{data = {coords = vector4(3000.72, 2777.08, 43.08, 211.7), prop = `prop_worklight_02a`}, freeze = true, sync = false}, -- Quarry Light
	{data = {coords = vector4(2998.0, 2767.45, 42.71, 249.22), prop = `prop_worklight_02a`}, freeze = true, sync = false},  -- Quarry Light
	{data = {coords = vector4(2959.93, 2755.26, 43.71, 164.24), prop = `prop_worklight_02a`}, freeze = true, sync = false},  -- Quarry Light
	{data = {coords = vector4(1106.46, -1991.44, 31.49, 185.78), prop = `prop_worklight_02a`}, freeze = true, sync = false} -- Foundary Light
}
local ActionByType = {
	["Smelter"] = Menu.OpenCraftMenu,
	["MineStore"] = Menu.OpenStoreMenu,
	["OreBuyer"] = Menu.OpenSellOreMenu,
	["JewelBuyer"] = Menu.OpenSellJewelMenu
}
local Positions = {}

function InitProps()
	for i,v in ipairs(DefaultProps) do
		Entity.Prop.Create(v.data, v.freeze, v.sync)
	end
	print('[^2JIM-MINING^7] Props loaded')
end

function RemoveJobSpecs()
	for _, v in pairs(Entity.Ped.List) do 
		Model.Unload(GetEntityModel(v)) 
		DeletePed(v) 
	end
	Entity.Ped.List = {}
	for i = 1, #Entity.Prop.List do
		Model.Unload(GetEntityModel(Entity.Prop.List[i])) 
		DeleteObject(Entity.Prop.List[i]) 
	end
	Entity.Prop.List = {}
	for i = 1, #Blip.List do 
		RemoveBlip(Blip.List[i])
	end
	Blip.List = {}
	Positions = {}
end

function InitJobSpecs()
	RemoveJobSpecs()
	if not Config.K4MB1Only then

		if Config.propSpawn then
			if Config.HangingLights then
				for k, v in pairs(Config.MineLights) do
					if Config.propSpawn then Entity.Prop.List[#Props+1] = Entity.Prop.Create({coords = v, prop = `xs_prop_arena_lights_ceiling_l_c`}, 1, false) end
				end
			end
			if not Config.HangingLights then
				for k, v in pairs(Config.WorkLights) do
					if Config.propSpawn then Entity.Prop.List[#Props+1] = Entity.Prop.Create({coords = v, prop = `prop_worklight_03a`}, 1, false) end
				end
			end
		end

		for k,v in pairs(Config.Locations) do
			for i,v2 in ipairs(v) do
				if v2.prop then -- PROP
					Entity.Prop.Create(v, true, false)
				end
				if v2.model then -- PED
					Entity.Ped.Create(v.model, v.coords, true, true, v.scenario, nil, ActionByType[k]) -- ADAPT ACTION TO PED
				end
				if v2.blipTrue then
					Blip.Create(v)
				end
				if not v2.model and not v2.prop then
					table.insert(Positions[k], {
						coords = v2.coords,
						action = PosActions[k]
					})
				end
			end
		end

		--Ore Spawning
		for k, v in pairs(Config.OrePositions) do
			Props[#Props+1] = makeProp({coords = v, prop = `cs_x_rubweec`}, 1, false)
			Targets["Ore"..k] =
				exports['qb-target']:AddCircleZone("Ore"..k, vector3(v.x, v.y, v.z-1.03), 1.2, { name="Ore"..k, debugPoly=Config.Debug, useZ=true, },
				{ options = {
					{ event = "jim-mining:MineOre:Pick", icon = "fas fa-hammer", item = "pickaxe", label = Loc[Config.Lan].info["mine_ore"].." ("..QBCore.Shared.Items["pickaxe"].label..")", job = Config.Job, name = "Ore"..k, stone = Props[#Props] },
					{ event = "jim-mining:MineOre:Drill", icon = "fas fa-screwdriver", item = "miningdrill", label = Loc[Config.Lan].info["mine_ore"].." ("..QBCore.Shared.Items["miningdrill"].label..")", job = Config.Job, name = "Ore"..k, stone = Props[#Props] },
					{ event = "jim-mining:MineOre:Laser", icon = "fas fa-screwdriver-wrench", item = "mininglaser", label = Loc[Config.Lan].info["mine_ore"].." ("..QBCore.Shared.Items["mininglaser"].label..")", job = Config.Job, name = "Ore"..k, stone = Props[#Props] },
				}, distance = 1.3 })
			Props[#Props+1] = makeProp({coords = vector4(v.x, v.y, v.z+0.25, v[4]), prop = `prop_rock_5_a`}, 1, false)
		end
	else 
		Config.K4MB1 = true 
	end

	
end

function itemProgress(data)
	if data.craftable then
		if not data.ret then bartext = Loc[Config.Lan].info["smelting"]..QBCore.Shared.Items[data.item].label
		else bartext = Loc[Config.Lan].info["cutting"]..QBCore.Shared.Items[data.item].label end
	end
	-- LocalPlayer.state:set("inv_busy", true, true) TriggerEvent('inventory:client:busy:status', true) TriggerEvent('canUseInventoryAndHotbar:toggle', false)
	local isDrilling = true
	if data.ret then -- If jewelcutting
		local drillcoords
		local scene
		local dict = "anim@amb@machinery@speed_drill@"
		local anim = "operate_02_hi_amy_skater_01"
		loadAnimDict(tostring(dict))
		for _, v in pairs(Props) do
			if #(GetEntityCoords(v) - GetEntityCoords(PlayerPedId())) <= 2.0 and GetEntityModel(v) == `gr_prop_gr_speeddrill_01c` then
				loadDrillSound()
				PlaySoundFromEntity(soundId, "Drill", v, "DLC_HEIST_FLEECA_SOUNDSET", 0.5, 0)
				drillcoords = GetOffsetFromEntityInWorldCoords(v, 0.0, -0.15, 0.0)
				scene = NetworkCreateSynchronisedScene(GetEntityCoords(v), GetEntityRotation(v), 2, false, false, 1065353216, 0, 1.3)
				NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, tostring(dict), tostring(anim), 0, 0, 0, 16, 1148846080, 0)
				NetworkStartSynchronisedScene(scene)
				break
			end
		end
		CreateThread(function()
			loadPtfxDict("core")
			while isDrilling do
				UseParticleFxAssetNextCall("core")
				local dust = StartNetworkedParticleFxNonLoopedAtCoord("glass_side_window", drillcoords.x, drillcoords.y, drillcoords.z+1.1, 0.0, 0.0, GetEntityHeading(PlayerPedId())+math.random(0, 359), 0.2, 0.0, 0.0, 0.0)
				Wait(100)
			end
		end)
	else -- If not Jewel Cutting, you'd be smelting (need to work out what is possible for this)
		animDictNow = "amb@prop_human_parking_meter@male@idle_a"
		animNow = "idle_a"
	end
	QBCore.Functions.Progressbar('making_food', bartext, Config.Timings["Crafting"], false, true, { disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true, },
	{ animDict = animDictNow, anim = animNow, flags = 8, }, {}, {}, function()
		TriggerServerEvent('jim-mining:GetItem', data)
		if data.ret then
			if math.random(1,10) >= 8 then
				local breakId = GetSoundId()
				PlaySoundFromEntity(breakId, "Drill_Pin_Break", PlayerPedId(), "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
				toggleItem(false, "drillbit", 1)
			end
		end
		LocalPlayer.state:set("inv_busy", false, true) TriggerEvent('inventory:client:busy:status', false) TriggerEvent('canUseInventoryAndHotbar:toggle', true)
		unloadDrillSound()
		StopSound(soundId)
		unloadPtfxDict("core")
		isDrilling = false
		NetworkStopSynchronisedScene(scene)
	end, function() -- Cancel
		triggerNotify(nil, Loc[Config.Lan].error["cancelled"], 'error')
		StopAnimTask(PlayerPedId(), animDictNow, animNow, 1.0)
		LocalPlayer.state:set("inv_busy", false, true) TriggerEvent('inventory:client:busy:status', false) TriggerEvent('canUseInventoryAndHotbar:toggle', true)
		unloadDrillSound()
		StopSound(soundId)
		unloadPtfxDict("core")
		unloadAnimDict(dict)
		isDrilling = false
		NetworkStopSynchronisedScene(scene)
	end, data.item)
end

function stoneBreak(name, stone)
	local rockcoords = GetEntityCoords(stone)
	if Config.Debug then print("^5Debug^7: ^2Hiding prop and target^7: '^6"..name.."^7' ^2at coords^7: ^6"..rockcoords) end
	--Stone CoolDown + Recreation
	SetEntityAlpha(stone, 0)
	--CreateModelHide(rockcoords, 1.0, `cs_x_rubweec`, true)
	exports['qb-target']:RemoveZone(name) Targets[name] = nil
	Wait(Config.Timings["OreRespawn"])
	--Unhide Stone and create a new target location
	SetEntityAlpha(stone, 255)
	--RemoveModelHide(rockcoords, 1.0, `cs_x_rubweec`, true)
	Targets[name] =
		exports['qb-target']:AddCircleZone(name, vector3(rockcoords.x, rockcoords.y, rockcoords.z), 1.2, { name=name, debugPoly=Config.Debug, useZ=true, },
		{ options = {
			{ event = "jim-mining:MineOre:Pick", icon = "fas fa-hammer", item = "pickaxe", label = Loc[Config.Lan].info["mine_ore"].." ("..QBCore.Shared.Items["pickaxe"].label..")", job = Config.Job, name = name, stone = stone },
			{ event = "jim-mining:MineOre:Drill", icon = "fas fa-screwdriver", item = "miningdrill", label = Loc[Config.Lan].info["mine_ore"].." ("..QBCore.Shared.Items["miningdrill"].label..")", job = Config.Job, name = name, stone = stone },
			{ event = "jim-mining:MineOre:Laser", icon = "fas fa-screwdriver-wrench", item = "mininglaser", label = Loc[Config.Lan].info["mine_ore"].." ("..QBCore.Shared.Items["mininglaser"].label..")", job = Config.Job, name = name, stone = stone },
			}, distance = 1.3 })
end