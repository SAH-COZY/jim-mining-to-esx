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
	["Cracking"] = CrackStart,
	["Washing"] = WashStart,
	['Panning'] = PanStart
}
soundId = GetSoundId()
PlayerData = {}
Positions = {}

LocalPlayer = {
	IsMining = false,
	IsCracking = false,
	IsWashing = false,
	IsPanning = false
}

ToolsData = {
	['mininglaser'] = Laser,
	['miningdrill'] = Drill,
	['pickaxe'] = Pick
}

Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(20) end
    PlayerData = ESX.GetPlayerData()
    while not PlayerData.job do PlayerData = ESX.GetPlayerData() Wait(500) end
	CreateModelHide(vector3(-596.04, 2089.01, 131.41), 10.5, -1241212535, true)
	InitProps()
end)
------------------------------------------------------------

InteractionsByPropModel = {
	[tostring(GetHashKey('gr_prop_gr_speeddrill_01c'))] = {
		help_text = "Press ~INPUT_CONTEXT~ to use jewel cutter",
		interaction_radius = 1.0,
		action = ActionByType["JewelCut"]
	},
	[tostring(GetHashKey('prop_vertdrill_01'))] = {
		help_text = "Press ~INPUT_CONTEXT~ to use stone cracker",
		interaction_radius = 1.0,
		action = ActionByType["Cracking"]
	}, 
	[tostring(GetHashKey('cs_x_rubweec'))] = {
		help_text = "Press ~INPUT_CONTEXT~ to mine",
		interaction_radius = 1.0,
		action = RockInteraction
	},
	[tostring(GetHashKey('prop_rock_5_a'))] = {
		help_text = "Press ~INPUT_CONTEXT~ to mine",
		interaction_radius = 1.0,
		action = RockInteraction
	},
}