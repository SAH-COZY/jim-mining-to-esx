ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

DefaultProps = {
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
ActionByType = {
	["Smelter"] = Menu.OpenCraftMenu,
	["MineStore"] = Menu.OpenStoreMenu,
	["OreBuyer"] = Menu.OpenSellOreMenu,
	["JewelBuyer"] = Menu.OpenSellJewelMenu,
	["JewelCut"] = Menu.OpenCraftMenu,
	["Cracking"] = function() return end, -- CREATE STONE CRACK FUNCTION. Ref: stone_crack
}
InteractionsByPropModel = {
	[tostring(GetHashKey('gr_prop_gr_speeddrill_01c'))] = {
		help_text = "Press ~INPUT_CONTEXT~ to use jewel cutter",
		interaction_radius = 1.0,
		action = ActionByType["JewelCut"]
	},
	[tostring(GetHashKey('prop_vertdrill_01'))] = {
		help_text = "Press ~INPUT_CONTEXT~ to use stone cracker",
		interaction_radius = 1.0,
		action = ActionByType["Cracking"] -- WHEN STONE CRACKING FUNCTION WILL BE CREATED, UPDATE THIS. Ref: stone_crack
	}, 
	[tostring(GetHashKey('cs_x_rubweec'))] = {
		help_text = "Press ~INPUT_CONTEXT~ to mine",
		interaction_radius = 2.0,
		action = StoneBreak
	},
	[tostring(GetHashKey('prop_rock_5_a'))] = {
		help_text = "Press ~INPUT_CONTEXT~ to mine",
		interaction_radius = 2.0,
		action = StoneBreak
	},
}
soundId = GetSoundId()
PlayerData = {}
Positions = {}

Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(20) end
    PlayerData = ESX.GetPlayerData()
    while not PlayerData.job do Wait(20) end
	InitProps()
end)
------------------------------------------------------------

--Hide the mineshaft doors
CreateModelHide(vector3(-596.04, 2089.01, 131.41), 10.5, -1241212535, true)

function removeJob()
	for k in pairs(Targets) do exports['qb-target']:RemoveZone(k) end
	for _, v in pairs(Peds) do unloadModel(GetEntityModel(v)) DeletePed(v) end
	for i = 1, #Props do unloadModel(GetEntityModel(Props[i])) DeleteObject(Props[i]) end
	for i = 1, #Blip do RemoveBlip(Blip[i]) end
end

function makeJob()
	removeJob()
	

	if Config.K4MB1 then
		for k, v in pairs(K4MB1["MineStore"]) do
			Targets["K4MB1Mine"..k] =
			exports['qb-target']:AddCircleZone("K4MB1Mine"..k, v.coords.xyz, 1.0, { name="K4MB1Mine"..k, debugPoly=Config.Debug, useZ=true, },
			{ options = { { event = "jim-mining:openShop", icon = "fas fa-store", label = Loc[Config.Lan].info["browse_store"], job = Config.Job }, },
			distance = 2.0 })
			if Config.Blips and v.blipTrue then Blip[#Blip+1] = makeBlip(v) end
			Peds[#Peds+1] = makePed(v.model, v.coords, 1, 1, v.scenario)
		end
		-- Smelter to turn stone into ore
		for k, v in pairs(K4MB1["Smelter"]) do
			Targets["K4MB1Smelter"..k] =
			exports['qb-target']:AddCircleZone("K4MB1Smelter"..k, v.coords.xyz, 1.5, { name="K4MB1Smelter"..k, debugPoly=Config.Debug, useZ=true, },
			{ options = { { event = "jim-mining:CraftMenu", icon = "fas fa-fire-burner", label = Loc[Config.Lan].info["use_smelter"], craftable = Crafting.SmeltMenu, job = Config.Job }, },
					distance = 10.0
				})
			if Config.Blips and v.blipTrue then Blip[#Blip+1] = makeBlip(v) end
		end
		-- Ore Buying Ped
		for k, v in pairs(K4MB1["OreBuyer"]) do
			if Config.Blips and v.blipTrue then Blip[#Blip+1] = makeBlip(v) end
			Peds[#Peds+1] = makePed(v.model, v.coords, 1, 1, v.scenario)
			Targets["K4MB1OreBuyer"..k] =
			exports['qb-target']:AddCircleZone("K4MB1OreBuyer"..k, v.coords.xyz, 0.9, { name="K4MB1OreBuyer"..k, debugPoly=Config.Debug, useZ=true, },
			{ options = { { event = "jim-mining:SellOre", icon = "fas fa-sack-dollar", label = Loc[Config.Lan].info["sell_ores"], ped = Peds[#Peds], job = Config.Job }, },
					distance = 2.0
				})
		end

		--Jewel Cutting Bench
		for k, v in pairs(K4MB1["JewelCut"]) do
			Props[#Props+1] = makeProp(v, 1, false)
			Targets["K4MB1JewelCut"..k] =
			exports['qb-target']:AddCircleZone("K4MB1JewelCut"..k, v.coords.xyz, 2.0,{ name="K4MB1JewelCut"..k, debugPoly=Config.Debug, useZ=true, },
			{ options = { { event = "jim-mining:JewelCut", icon = "fas fa-gem", label = Loc[Config.Lan].info["jewelcut"], job = Config.Job, bench = Props[#Props]}, },
				distance = 2.0
			})
			if Config.Blips and v.blipTrue then Blip[#Blip+1] = makeBlip(v) end
		end
		--Cracking Bench
		for k, v in pairs(K4MB1["Cracking"]) do
			if Config.Blips and v.blipTrue then Blip[#Blip+1] = makeBlip(v) end
			Props[#Props+1] = makeProp(v, 1, false)
			Targets["K4MB1Cracking"..k] =
				exports['qb-target']:AddCircleZone("K4MB1Cracking"..k, v.coords.xyz, 1.2, {name="K4MB1Cracking"..k, debugPoly=Config.Debug, useZ=true, },
				{ options = { { event = "jim-mining:CrackStart", icon = "fas fa-compact-disc", item = "stone", label = Loc[Config.Lan].info["crackingbench"], bench = Props[#Props] }, },
				distance = 2.0
			})
		end
		--Ore Spawning
		for k, v in pairs(K4MB1["OrePositions"]) do
			Props[#Props+1] = makeProp({coords = v, prop = `cs_x_rubweec`}, 1, false)
			Targets["K4MB1Ore"..k] =
			exports['qb-target']:AddCircleZone("K4MB1Ore"..k, vector3(v.x, v.y, v.z-1.03), 1.2, { name="K4MB1Ore"..k, debugPoly=Config.Debug, useZ=true, },
			{ options = {
				{ event = "jim-mining:MineOre:Pick", icon = "fas fa-hammer", item = "pickaxe", label = Loc[Config.Lan].info["mine_ore"].." ("..QBCore.Shared.Items["pickaxe"].label..")", job = Config.Job, name = "K4MB1Ore"..k, stone = Props[#Props] },
				{ event = "jim-mining:MineOre:Drill", icon = "fas fa-screwdriver", item = "miningdrill", label = Loc[Config.Lan].info["mine_ore"].." ("..QBCore.Shared.Items["miningdrill"].label..")", job = Config.Job, name = "K4MB1Ore"..k, stone = Props[#Props] },
				{ event = "jim-mining:MineOre:Laser", icon = "fas fa-screwdriver-wrench", item = "mininglaser", label = Loc[Config.Lan].info["mine_ore"].." ("..QBCore.Shared.Items["mininglaser"].label..")", job = Config.Job, name = "K4MB1Ore"..k, stone = Props[#Props] },
				},
				distance = 1.3
			})
			Props[#Props+1] = makeProp({coords = vector4(v.x, v.y, v.z+0.25, v[4]), prop = `prop_rock_5_a`}, 1, false)
		end
	end
	for k, v in pairs(Config.Locations["Washing"]) do
		Targets["Washing"..k] =
			exports['qb-target']:AddCircleZone("Washing"..k, v.coords.xyz, 9.0, {name="Washing"..k, debugPoly=Config.Debug, useZ=true, },
			{ options = { { event = "jim-mining:WashStart", icon = "fas fa-hands-bubbles", item = "stone", label = Loc[Config.Lan].info["washstone"], coords = v.coords }, },
				distance = 2.0
			})
		if Config.Blips and v.blipTrue then Blip[#Blip+1] = makeBlip(v) end
	end
	--Panning
	for k, v in pairs(Config.Locations["Panning"]) do
		Targets["Panning"..k] =
			exports['qb-target']:AddCircleZone("Panning"..k, v.coords.xyz, 9.0, {name="Panning"..k, debugPoly=Config.Debug, useZ=true, },
			{ options = { { event = "jim-mining:PanStart", icon = "fas fa-ring", item = "goldpan", label = Loc[Config.Lan].info["goldpan"], coords = v.coords }, },
				distance = 2.0
			})
		if Config.Blips and v.blipTrue then Blip[#Blip+1] = makeBlip(v) end
	end
	--Jewel Buyer
	for k, v in pairs(Config.Locations["JewelBuyer"]) do
		Peds[#Peds+1] = makePed(v.model, v.coords, 1, 1, v.scenario)
		Targets["JewelBuyer"..k] =
			exports['qb-target']:AddCircleZone("JewelBuyer"..k, v.coords.xyz, 1.2, { name="JewelBuyer"..k, debugPoly=Config.Debug, useZ=true, },
			{ options = { { event = "jim-mining:JewelSell", icon = "fas fa-gem", label = Loc[Config.Lan].info["jewelbuyer"], ped = Peds[#Peds], job = Config.Job }, },
				distance = 2.0
			})
	end
end

-- RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
-- 	QBCore.Functions.GetPlayerData(function(PlayerData)	PlayerJob = PlayerData.job end)
-- 	if Config.Job then if PlayerJob.name == Config.Job then makeJob() else removeJob() end else makeJob() end
-- end)
-- RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
-- 	PlayerJob = JobInfo
-- 	if Config.Job then if PlayerJob.name == Config.Job then makeJob() else removeJob() end end
-- end)
-- AddEventHandler('onResourceStart', function(resource) if GetCurrentResourceName() ~= resource then return end
-- QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end)
-- if Config.Job then if PlayerJob.name == Config.Job then makeJob() else removeJob() end else makeJob() end
-- end)

--------------------------------------------------------
-- RegisterNetEvent('jim-mining:openShop', function()
-- 	if Config.JimShops then event = "jim-shops:ShopOpen" else event = "inventory:server:OpenInventory" end -- FAIT (Menu.OpenStoreMenu)
-- 	TriggerServerEvent(event, "shop", "mine", Config.Items)
-- end)

local isMining = false
RegisterNetEvent('jim-mining:MineOre:Drill', function(data)
	if isMining then return else isMining = true end -- Stop players from doubling up the event
	if HasItem("drillbit", 1) then
		-- Sounds & Anim loading
		loadDrillSound()
		local dict = "anim@heists@fleeca_bank@drilling"
		local anim = "drill_straight_fail"
		loadAnimDict(tostring(dict))
		--Create Drill and Attach
		local DrillObject = CreateObject(`hei_prop_heist_drill`, GetEntityCoords(PlayerPedId(), true), true, true, true)
		AttachEntityToEntity(DrillObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0, -0.01, 90.0, -90.0, 180.0, true, true, false, true, 1, true)
		local IsDrilling = true
		local rockcoords = GetEntityCoords(data.stone)
		--Calculate if you're heading is within 20.0 degrees -
		lookEnt(data.stone)
		if #(rockcoords - GetEntityCoords(PlayerPedId())) > 1.5 then TaskGoStraightToCoord(PlayerPedId(), rockcoords, 0.5, 400, 0.0, 0) Wait(400) end
		TaskPlayAnim(PlayerPedId(), tostring(dict), tostring(anim), 3.0, 3.0, -1, 1, 0, false, false, false)
		Wait(200)
		PlaySoundFromEntity(soundId, "Drill", DrillObject, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
		CreateThread(function() -- Dust/Debris Animation
			loadPtfxDict("core")
			while IsDrilling do
				UseParticleFxAssetNextCall("core")
				local dust = StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_rocks", rockcoords.x, rockcoords.y, rockcoords.z, 0.0, 0.0, GetEntityHeading(PlayerPedId())-180.0, 1.0, 0.0, 0.0, 0.0)
				Wait(600)
			end
		end)
		QBCore.Functions.Progressbar("open_locker_drill", Loc[Config.Lan].info["drilling_ore"], Config.Timings["Mining"], false, true, {
			disableMovement = true,	disableCarMovement = true, disableMouse = false, disableCombat = true, }, {}, {}, {}, function() -- Done
			StopAnimTask(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_fail", 1.0)
			destroyProp(DrillObject)
			unloadPtfxDict("core")
			unloadAnimDict(dict)
			TriggerServerEvent('jim-mining:MineReward')
			--Destroy drill bit chances
			if math.random(1,10) >= 8 then
				local breakId = GetSoundId()
				PlaySoundFromEntity(breakId, "Drill_Pin_Break", PlayerPedId(), "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
				toggleItem(0, "drillbit", 1)
			end
			unloadDrillSound()
			StopSound(soundId)
			IsDrilling = false
			isMining = false
			stoneBreak(data.name, data.stone)
		end, function() -- Cancel
			StopAnimTask(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 1.0)
			unloadDrillSound()
			StopSound(soundId)
			destroyProp(DrillObject)
			unloadPtfxDict("core")
			unloadAnimDict(dict)
			IsDrilling = false
			isMining = false
		end, "miningdrill")
	else
		triggerNotify(nil, Loc[Config.Lan].error["no_drillbit"], nil) isMining = false return
	end
end)

RegisterNetEvent('jim-mining:MineOre:Pick', function(data)
	if isMining then return else isMining = true end -- Stop players from doubling up the event
	-- Anim Loading
	local dict = "amb@world_human_hammering@male@base"
	local anim = "base"
	loadAnimDict(tostring(dict))
	loadDrillSound()
	--Create Pickaxe and Attach
	local PickAxe = CreateObject(`prop_tool_pickaxe`, GetEntityCoords(PlayerPedId(), true), true, true, true)
	DisableCamCollisionForObject(PickAxe)
	DisableCamCollisionForEntity(PickAxe)
	AttachEntityToEntity(PickAxe, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.09, -0.53, -0.22, 252.0, 180.0, 0.0, false, true, true, true, 0, true)
	local IsDrilling = true
	local rockcoords = GetEntityCoords(data.stone)
	--Calculate if you're facing the stone--
	lookEnt(data.stone)
	if #(rockcoords - GetEntityCoords(PlayerPedId())) > 1.5 then TaskGoStraightToCoord(PlayerPedId(), rockcoords, 0.5, 400, 0.0, 0) Wait(400) end
	loadPtfxDict("core")
	CreateThread(function()
		while IsDrilling do
			UseParticleFxAssetNextCall("core")
			TaskPlayAnim(PlayerPedId(), tostring(dict), tostring(anim), 8.0, -8.0, -1, 2, 0, false, false, false)
			Wait(200)
			local pickcoords = GetOffsetFromEntityInWorldCoords(PickAxe, -0.4, 0.0, 0.7)
			local dust = StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_rocks", pickcoords.x, pickcoords.y, pickcoords.z, 0.0, 0.0, 0.0, 0.4, 0.0, 0.0, 0.0)
			Wait(350)
		end
	end)
	QBCore.Functions.Progressbar("open_locker_drill", Loc[Config.Lan].info["drilling_ore"], Config.Timings["Pickaxe"], false, true, {
		disableMovement = true,	disableCarMovement = true, disableMouse = false, disableCombat = true, }, {}, {}, {}, function() -- Done
		StopAnimTask(PlayerPedId(), tostring(dict), tostring(anim), 1.0)
		destroyProp(PickAxe)
		unloadPtfxDict("core")
		unloadAnimDict(dict)
		TriggerServerEvent('jim-mining:MineReward')
		if math.random(1,10) >= 9 then
			local breakId = GetSoundId()
			PlaySoundFromEntity(breakId, "Drill_Pin_Break", PlayerPedId(), "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
			toggleItem(false, "pickaxe", 1)
		end
		unloadDrillSound()
		StopSound(soundId)
		IsDrilling = false
		isMining = false
		stoneBreak(data.name, data.stone)
	end, function() -- Cancel
		StopAnimTask(PlayerPedId(), tostring(dict), tostring(anim), 1.0)
		destroyProp(PickAxe)
		unloadPtfxDict("core")
		unloadAnimDict(dict)
		unloadDrillSound()
		StopSound(soundId)
		IsDrilling = false
		isMining = false
	end, "pickaxe")
end)

RegisterNetEvent('jim-mining:MineOre:Laser', function(data)
	if isMining then return else isMining = true end -- Stop players from doubling up the event
	-- Sounds & Anim Loading
	RequestAmbientAudioBank("DLC_HEIST_BIOLAB_DELIVER_EMP_SOUNDS", 0)
	RequestAmbientAudioBank("dlc_xm_silo_laser_hack_sounds", 0)
	local dict = "anim@heists@fleeca_bank@drilling"
	local anim = "drill_straight_fail"
	loadAnimDict(tostring(dict))
	--Create Drill and Attach
	local DrillObject = CreateObject(`ch_prop_laserdrill_01a`, GetEntityCoords(PlayerPedId(), true), true, true, true)
	AttachEntityToEntity(DrillObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0, -0.01, 90.0, -90.0, 180.0, true, true, false, true, 1, true)
	local IsDrilling = true
	local rockcoords = GetEntityCoords(data.stone)
	--Calculate if you're facing the stone--
	lookEnt(data.stone)
	--Activation noise & Anims
	TaskPlayAnim(PlayerPedId(), tostring(dict), 'drill_straight_idle' , 3.0, 3.0, -1, 1, 0, false, false, false)
	PlaySoundFromEntity(soundId, "Pass", DrillObject, "dlc_xm_silo_laser_hack_sounds", 1, 0) Wait(1000)
	TaskPlayAnim(PlayerPedId(), tostring(dict), tostring(anim), 3.0, 3.0, -1, 1, 0, false, false, false)
	PlaySoundFromEntity(soundId, "EMP_Vehicle_Hum", DrillObject, "DLC_HEIST_BIOLAB_DELIVER_EMP_SOUNDS", 1, 0) --Not sure about this sound, best one I could find as everything else wouldn't load
	--Laser & Debris Effect
	local lasercoords = GetOffsetFromEntityInWorldCoords(DrillObject, 0.0,-0.5, 0.02)
	CreateThread(function()
		loadPtfxDict("core")
		while IsDrilling do
			UseParticleFxAssetNextCall("core")
			local laser = StartNetworkedParticleFxNonLoopedAtCoord("muz_railgun", lasercoords.x, lasercoords.y, lasercoords.z, 0, -10.0, GetEntityHeading(DrillObject)+270, 1.0, 0.0, 0.0, 0.0)
			UseParticleFxAssetNextCall("core")
			local dust = StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_rocks", rockcoords.x, rockcoords.y, rockcoords.z, 0.0, 0.0, GetEntityHeading(PlayerPedId())-180.0, 1.0, 0.0, 0.0, 0.0)
			Wait(60)
		end
	end)
	QBCore.Functions.Progressbar("open_locker_drill", Loc[Config.Lan].info["drilling_ore"], (Config.Timings["Laser"]), false, true, {
		disableMovement = true,	disableCarMovement = true, disableMouse = false, disableCombat = true, }, {}, {}, {}, function() -- Done
		IsDrilling = false
		isMining = false
		StopAnimTask(PlayerPedId(), tostring(dict), tostring(anim), 1.0)
		ReleaseAmbientAudioBank("DLC_HEIST_BIOLAB_DELIVER_EMP_SOUNDS")
		ReleaseAmbientAudioBank("dlc_xm_silo_laser_hack_sounds")
		StopSound(soundId)
		destroyProp(DrillObject)
		unloadPtfxDict("core")
		unloadAnimDict(dict)
		TriggerServerEvent('jim-mining:MineReward')
		stoneBreak(data.name, data.stone)
	end, function() -- Cancel
		IsDrilling = false
		isMining = false
		StopAnimTask(PlayerPedId(), tostring(dict), tostring(anim), 1.0)
		ReleaseAmbientAudioBank("DLC_HEIST_BIOLAB_DELIVER_EMP_SOUNDS")
		ReleaseAmbientAudioBank("dlc_xm_silo_laser_hack_sounds")
		StopSound(soundId)
		destroyProp(DrillObject)
		unloadPtfxDict("core")
		unloadAnimDict(dict)
		stoneBreak(data.name, data.stone)
		IsDrilling = false
		isMining = false
	end, "mininglaser")
end)
------------------------------------------------------------
-- Cracking Command / Animations
local Cracking = false
RegisterNetEvent('jim-mining:CrackStart', function(data)
	if Cracking then return end
	local cost = 1
	if HasItem("stone", cost) then
		Cracking = true
		LocalPlayer.state:set("inv_busy", true, true) TriggerEvent('inventory:client:busy:status', true) TriggerEvent('canUseInventoryAndHotbar:toggle', false)
		-- Sounds & Anim Loading
		local dict ="amb@prop_human_parking_meter@male@idle_a"
		local anim = "idle_a"
		loadAnimDict(dict)
		loadDrillSound()
		local benchcoords = GetOffsetFromEntityInWorldCoords(data.bench, 0.0, -0.2, 2.08)
		--Calculate if you're facing the bench--
		lookEnt(data.bench)
		if #(benchcoords - GetEntityCoords(PlayerPedId())) > 1.5 then TaskGoStraightToCoord(PlayerPedId(), benchcoords, 0.5, 400, 0.0, 0) Wait(400) end

		local Rock = CreateObject(`prop_rock_5_smash1`, vector3(benchcoords.x, benchcoords.y, benchcoords.z-1.03), true, true, true)
		PlaySoundFromCoord(soundId, "Drill", benchcoords, "DLC_HEIST_FLEECA_SOUNDSET", 0, 4.5, 0)
		loadPtfxDict("core")
		CreateThread(function()
			while Cracking do
				UseParticleFxAssetNextCall("core")
				local dust = StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_rocks", benchcoords.x, benchcoords.y, benchcoords.z-0.9, 0.0, 0.0, 0.0, 0.2, 0.0, 0.0, 0.0)
				Wait(400)
			end
		end)
		TaskPlayAnim(PlayerPedId(), dict, anim, 3.0, 3.0, -1, 1, 0, false, false, false)
		QBCore.Functions.Progressbar("open_locker_drill", Loc[Config.Lan].info["cracking_stone"], Config.Timings["Cracking"], false, true, {
			disableMovement = true,	disableCarMovement = true, disableMouse = false, disableCombat = true, }, {}, {}, {}, function() -- Done
			StopAnimTask(PlayerPedId(), dict, anim, 1.0)
			unloadDrillSound()
			StopSound(soundId)
			unloadPtfxDict("core")
			unloadAnimDict(dict)
			destroyProp(Rock)
			TriggerServerEvent('jim-mining:CrackReward', cost)
			LocalPlayer.state:set("inv_busy", false, true) TriggerEvent('inventory:client:busy:status', false) TriggerEvent('canUseInventoryAndHotbar:toggle', true)
			Cracking = false
		end, function() -- Cancel
			StopAnimTask(PlayerPedId(), dict, anim, 1.0)
			unloadDrillSound()
			StopSound(soundId)
			unloadPtfxDict("core")
			unloadAnimDict(dict)
			destroyProp(Rock)
			LocalPlayer.state:set("inv_busy", false, true) TriggerEvent('inventory:client:busy:status', false) TriggerEvent('canUseInventoryAndHotbar:toggle', true)
			Cracking = false
		end, "stone")
	else
		triggerNotify(nil, Loc[Config.Lan].error["no_stone"], 'error')
	end
end)
------------------------------------------------------------
-- Washing Command / Animations
local Washing = false
RegisterNetEvent('jim-mining:WashStart', function(data)
	if Washing then return end
	local cost = 1
	if HasItem("stone", cost) then
		Washing = true
		LocalPlayer.state:set("inv_busy", true, true) TriggerEvent('inventory:client:busy:status', true) TriggerEvent('canUseInventoryAndHotbar:toggle', false)
		--Create Rock and Attach
		local Rock = CreateObject(`prop_rock_5_smash1`, GetEntityCoords(PlayerPedId()), true, true, true)
		local rockcoords = GetEntityCoords(Rock)
		AttachEntityToEntity(Rock, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.1, 0.0, 0.05, 90.0, -90.0, 90.0, true, true, false, true, 1, true)
		TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
		local water
		CreateThread(function()
			Wait(3000)
			loadPtfxDict("core")
			while Washing do
				UseParticleFxAssetNextCall("core")
				water = StartNetworkedParticleFxLoopedOnEntity("water_splash_veh_out", PlayerPedId(), 0.0, 1.0, -0.2, 0.0, 0.0, 0.0, 2.0, 0, 0, 0)
				Wait(500)
			end
		end)
		QBCore.Functions.Progressbar("open_locker_drill", Loc[Config.Lan].info["washing_stone"], Config.Timings["Washing"], false, true, {
			disableMovement = true,	disableCarMovement = true, disableMouse = false, disableCombat = true, }, {}, {}, {}, function() -- Done
			TriggerServerEvent('jim-mining:WashReward', cost)
			LocalPlayer.state:set("inv_busy", false, true) TriggerEvent('inventory:client:busy:status', false) TriggerEvent('canUseInventoryAndHotbar:toggle', true)
			StopParticleFxLooped(water, 0)
			destroyProp(Rock)
			unloadPtfxDict("core")
			Washing = false
		end, function() -- Cancel
			LocalPlayer.state:set("inv_busy", false, true) TriggerEvent('inventory:client:busy:status', false) TriggerEvent('canUseInventoryAndHotbar:toggle', true)
			StopParticleFxLooped(water, 0)
			destroyProp(Rock)
			unloadPtfxDict("core")
			Washing = false
		end, "stone")
	else
		triggerNotify(nil, Loc[Config.Lan].error["no_stone"], 'error')
	end
end)
------------------------------------------------------------
-- Gold Panning Command / Animations
local Panning = false
RegisterNetEvent('jim-mining:PanStart', function(data)
	if IsEntityInWater(PlayerPedId()) then
		if Panning then return else Panning = true end
		LocalPlayer.state:set("inv_busy", true, true) TriggerEvent('inventory:client:busy:status', true) TriggerEvent('canUseInventoryAndHotbar:toggle', false)
		--Create Rock and Attach
		local trayCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.5, -0.9)
		Props[#Props+1] = makeProp({ coords = vector4(trayCoords.x, trayCoords.y, trayCoords.z+1.03, GetEntityHeading(PlayerPedId())), prop = `bkr_prop_meth_tray_01b`} , 1, 1)
		CreateThread(function()
			loadPtfxDict("core")
			while Panning do
				UseParticleFxAssetNextCall("core")
				local water = StartNetworkedParticleFxLoopedOnEntity("water_splash_veh_out", Props[#Props], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 0, 0, 0)
				Wait(100)
			end
		end)
		--Start Anim
		TaskStartScenarioInPlace(PlayerPedId(), "CODE_HUMAN_MEDIC_KNEEL", 0, true)
		QBCore.Functions.Progressbar("open_locker_drill", Loc[Config.Lan].info["goldpanning"], Config.Timings["Panning"], false, true, {
			disableMovement = true,	disableCarMovement = true, disableMouse = false, disableCombat = true, }, {}, {}, {}, function() -- Done
			TriggerServerEvent('jim-mining:PanReward')
			ClearPedTasksImmediately(PlayerPedId())
			TaskGoStraightToCoord(PlayerPedId(), trayCoords, 4.0, 100, GetEntityHeading(PlayerPedId()), 0)
			destroyProp(Props[#Props])
			unloadPtfxDict("core")
			-- LocalPlayer.state:set("inv_busy", false, true) TriggerEvent('inventory:client:busy:status', false) TriggerEvent('canUseInventoryAndHotbar:toggle', true)
			Panning = false
		end, function() -- Cance
			ClearPedTasksImmediately(PlayerPedId())
			TaskGoStraightToCoord(PlayerPedId(), trayCoords, 4.0, 100, GetEntityHeading(PlayerPedId()), 0)
			destroyProp(Props[#Props])
			unloadPtfxDict("core")
			-- LocalPlayer.state:set("inv_busy", false, true) TriggerEvent('inventory:client:busy:status', false) TriggerEvent('canUseInventoryAndHotbar:toggle', true)
			Panning = false
		end, "goldpan")
	end
end)

----------------------------------------

RegisterNetEvent('jim-mining:MakeItem', function(data)
	if data.ret then
		if not HasItem("drillbit", 1) then triggerNotify(nil, Loc[Config.Lan].error["no_drillbit"], 'error') TriggerEvent('jim-mining:JewelCut') return end
	end
	itemProgress(data)
end)



AddEventHandler('onResourceStop', function(resource) if resource == GetCurrentResourceName() then removeJob() end end)