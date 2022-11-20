function InitProps()
	for i,v in ipairs(DefaultProps) do
		Entity.Prop.Create(v.data, v.freeze, v.sync)
	end
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
	for k,_ in pairs(Blip.List) do 
		Blip.Remove(k)
	end
	Blip.List = {}
	Positions = {}
end

function InitJobSpecs()
	RemoveJobSpecs()
	if PlayerData.job.name == 'miner' then
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
						Entity.Prop.Create(v2, true, false)
					end
					if v2.model then -- PED
						Entity.Ped.Create(v2.model, v2.coords, true, true, v2.scenario, nil, ActionByType[k]) -- ADAPT ACTION TO PED
					end
					if v2.blipTrue then -- BLIP
						Blip.Create(v2)
					end
					if not v2.model and not v2.prop then -- IF NOT A PROP AND NOT A PED
						if not Positions[k] then Positions[k] = {} end
						table.insert(Positions[k], {
							coords = v2.coords,
							action = ActionByType[k]
						})
					end
				end
			end
			for k, v in pairs(Config.OrePositions) do
				local prop_rock_1 = Entity.Prop.Create({coords = v, prop = `cs_x_rubweec`}, true, false)
				-- local prop_rock_2 = Entity.Prop.Create({coords = vector4(v.x, v.y, v.z+0.25, v.w), prop = `prop_rock_5_a`}, true, false)
			end
		else 
			for k,v in pairs(K4MBI) do
				for i,v2 in ipairs(v) do
					if type(v2) ~= 'vector4' then
						if v2.prop then -- PROP
							Entity.Prop.Create(v2, true, false)
						end
						if v2.model then -- PED
							Entity.Ped.Create(v2.model, v2.coords, true, true, v2.scenario, nil, ActionByType[k]) -- ADAPT ACTION TO PED
						end
						if v2.blipTrue then -- BLIP
							Blip.Create(v2)
						end
						if not v2.model and not v2.prop then -- IF NOT A PROP AND NOT A PED
							if not Positions[k] then Positions[k] = {} end
							table.insert(Positions[k], {
								coords = v2.coords,
								action = ActionByType[k]
							})
						end
					else
						local prop_rock_1 = Entity.Prop.Create({coords = v2, prop = `cs_x_rubweec`}, true, false)
						-- local prop_rock_2 = Entity.Prop.Create({coords = vector4(v2.x, v2.y, v2.z+0.25, v2.w), prop = `prop_rock_5_a`}, 1, false)
					end
				end
			end
		end

		InitDetection()
	end
end

function InitDetection()
	Citizen.CreateThread(function()
		while true do
			if PlayerData.job.name ~= 'miner' then
				break
			end
			local interval = 400
			local objects, peds = GetGamePool("CObject"), GetGamePool('CPed')
			for i,v in ipairs(objects) do
				local player_coords = GetEntityCoords(PlayerPedId())
				local obj_coords = GetEntityCoords(v)
				local dist = #(player_coords - obj_coords)
				if Entity.Prop.List[v] and InteractionsByPropModel[tostring(GetEntityModel(v))] and Entity.IsVisible(v) then
					if dist <= 10.0 then
						interval = 1
						if dist <= 2.0 then
							local curr_prop_data = InteractionsByPropModel[tostring(GetEntityModel(v))]
							ESX.ShowHelpNotification(curr_prop_data.help_text, true)
							if IsControlJustPressed(0, 51) then
								curr_prop_data.action(v)
							end
						end
					end
				end
			end
			for i,v in ipairs(peds) do
				local player_coords = GetEntityCoords(PlayerPedId())
				local ped_coords = GetEntityCoords(v)
				local dist = #(player_coords - ped_coords)
				if dist <= 10.0 then
					if Entity.Ped.List[v] then
						interval = 1
						if dist <= 1.3 then
							if Entity.Ped.Actions[v] then
								ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to interact with ped', true)
								if IsControlJustPressed(0, 51) then
									Entity.Ped.Actions[v]()
								end
							end
						end
					end
				end
			end
			for k,v in pairs(Positions) do
				for _,v2 in ipairs(v) do
					local player_coords = GetEntityCoords(PlayerPedId())
					local dist = #(player_coords - v2.coords)
					if dist <= 10.0 then
						interval = 1
						if dist <= 4.0 then
							ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to interact', true)
							if IsControlJustPressed(0, 51) then
								v2.action()
							end
						end
					end
				end
			end

			Wait(interval)
		end
		return
	end)
end

function StoneBreak(entity_handle)
	local rockcoords = GetEntityCoords(entity_handle)
	SetEntityCollision(entity_handle, false, true)
	Entity.FadeOut(entity_handle)
	TriggerServerEvent('jim-mining:MineReward')
	SetTimeout(Config.Timings["OreRespawn"], function()
		Entity.FadeIn(entity_handle)
		SetEntityCollision(entity_handle, true, true)
		Entity.Prop.List[entity_handle] = true
	end)
end

function HaveItems(items)
	local bool = nil
	ESX.TriggerServerCallback('jim-mining:HaveItems', function(_bool)
		bool = _bool
	end, items)
	while not bool do Wait(1) end
	return bool
end

function GetPlayerBestTool()
	local str = nil
	ESX.TriggerServerCallback('jim-mining:GetPlayerBestTool', function(best_tool) 
		str = best_tool
	end)
	while not str do Wait(1) end
	return str
end

function UseTool(tool_name, rock_entity)
	if ToolsData[tool_name] then
		ToolsData[tool_name](rock_entity)
	end
end

function RockInteraction(rock_entity)
	local tool = GetPlayerBestTool()
	if tool then
		UseTool(tool, rock_entity)
	end
end

function Drill(entity_handle) 
	if LocalPlayer.IsMining then return else LocalPlayer.IsMining = true end
	if HaveItems("drillbit") then
		Sound.Load()
		local dict = "anim@heists@fleeca_bank@drilling"
		local anim = "drill_straight_fail"
		Anim.LoadDict(dict)
		--Create Drill and Attach
		local DrillObject = CreateObject(`hei_prop_heist_drill`, GetEntityCoords(PlayerPedId(), true), true, true, true)
		AttachEntityToEntity(DrillObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0, -0.01, 90.0, -90.0, 180.0, true, true, false, true, 1, true)
		LocalPlayer.IsMining = true
		LocalPlayer.IsDrilling = true
		local rockcoords = GetEntityCoords(entity_handle)
		--Calculate if you're heading is within 20.0 degrees -
		Entity.FaceToEntity(entity_handle)
		Entity.Prop.List[entity_handle] = false
		if #(rockcoords - GetEntityCoords(PlayerPedId())) > 1.5 then TaskGoStraightToCoord(PlayerPedId(), rockcoords, 0.5, 400, 0.0, 0) Wait(400) end
		TaskPlayAnim(PlayerPedId(), tostring(dict), tostring(anim), 3.0, 3.0, -1, 1, 0, false, false, false)
		Wait(200)
		PlaySoundFromEntity(soundId, "Drill", DrillObject, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
		CreateThread(function() -- Dust/Debris Animation
			PTFX.LoadAsset("core")
			while LocalPlayer.IsDrilling do
				UseParticleFxAssetNextCall("core")
				local dust = StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_rocks", rockcoords.x, rockcoords.y, rockcoords.z, 0.0, 0.0, GetEntityHeading(PlayerPedId())-180.0, 1.0, 0.0, 0.0, 0.0)
				Wait(600)
			end
		end)

		exports['rprogress']:Custom({
			Label = "Mining...",
			Duration = Config.Timings["Mining"],
			onComplete = function(cancelled)
				if not cancelled then
					StopAnimTask(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_fail", 1.0)
					Entity.Prop.Delete(DrillObject)
					PTFX.UnloadAsset("core")
					Anim.UnloadDict(dict)
					TriggerServerEvent('jim-mining:MineReward')
					--Destroy drill bit chances
					if math.random(1,10) >= 8 then
						local breakId = GetSoundId()
						PlaySoundFromEntity(breakId, "Drill_Pin_Break", PlayerPedId(), "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
						-- toggleItem(0, "drillbit", 1)
					end
					Sound.Unload()
					StopSound(soundId)
					LocalPlayer.IsDrilling = false
					LocalPlayer.IsMining = false
					StoneBreak(entity_handle)
				else
					StopAnimTask(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 1.0)
					Sound.Unload()
					StopSound(soundId)
					Entity.Prop.Delete(DrillObject)
					PTFX.UnloadAsset("core")
					Anim.UnloadDict(dict)
					LocalPlayer.IsDrilling = false
					LocalPlayer.IsMining = false
				end
			end
		})
	else
		-- triggerNotify(nil, Loc[Config.Lan].error["no_drillbit"], 'system') 
		ESX.ShowNotification('system', nil, Loc[Config.Lan].error["no_drillbit"])
		LocalPlayer.IsMining = false 
		return
	end
end

function Pick(entity_handle)
	if LocalPlayer.IsMining then return else LocalPlayer.IsMining = true end
	if HaveItems('pickaxe') then
		local dict = "amb@world_human_hammering@male@base"
		local anim = "base"
		Anim.LoadDict(dict)
		Sound.Load()
		local PickAxe = CreateObject(`prop_tool_pickaxe`, GetEntityCoords(PlayerPedId(), true), true, true, true)
		DisableCamCollisionForObject(PickAxe)
		DisableCamCollisionForEntity(PickAxe)
		AttachEntityToEntity(PickAxe, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.09, -0.53, -0.22, 252.0, 180.0, 0.0, false, true, true, true, 0, true)
		LocalPlayer.IsDrilling = true
		local rockcoords = GetEntityCoords(entity_handle)
		Entity.FaceToEntity(entity_handle)
		Entity.Prop.List[entity_handle] = false
		if #(rockcoords - GetEntityCoords(PlayerPedId())) > 1.5 then TaskGoStraightToCoord(PlayerPedId(), rockcoords, 0.5, 400, 0.0, 0) Wait(400) end
		PTFX.LoadAsset("core")
		CreateThread(function()
			while LocalPlayer.IsDrilling do
				UseParticleFxAssetNextCall("core")
				TaskPlayAnim(PlayerPedId(), tostring(dict), tostring(anim), 8.0, -8.0, -1, 2, 0, false, false, false)
				Wait(200)
				local pickcoords = GetOffsetFromEntityInWorldCoords(PickAxe, -0.4, 0.0, 0.7)
				local dust = StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_rocks", pickcoords.x, pickcoords.y, pickcoords.z, 0.0, 0.0, 0.0, 0.4, 0.0, 0.0, 0.0)
				Wait(350)
			end
		end)

		exports['rprogress']:Custom({
			Label = "Mining...",
			Duration = Config.Timings["Pickaxe"],
			onComplete = function(cancelled)
				if not cancelled then
					StopAnimTask(PlayerPedId(), tostring(dict), tostring(anim), 1.0)
					Entity.Prop.Delete(PickAxe)
					PTFX.UnloadAsset("core")
					Anim.UnloadDict(dict)
					TriggerServerEvent('jim-mining:MineReward')
					if math.random(1,10) >= 9 then
						local breakId = GetSoundId()
						PlaySoundFromEntity(breakId, "Drill_Pin_Break", PlayerPedId(), "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
						-- toggleItem(false, "pickaxe", 1)
					end
					Sound.Unload()
					StopSound(soundId)
					LocalPlayer.IsDrilling = false
					LocalPlayer.IsMining = false
					StoneBreak(entity_handle)
				else
					StopAnimTask(PlayerPedId(), tostring(dict), tostring(anim), 1.0)
					Entity.Prop.Delete(PickAxe)
					PTFX.UnloadAsset("core")
					Anim.UnloadDict(dict)
					Sound.Unload()
					StopSound(soundId)
					LocalPlayer.IsDrilling = false
					LocalPlayer.IsMining = false
				end
			end
		})
	else
		ESX.ShowNotification('system', nil, Loc[Config.Lan].error["no_pickaxe"])
	end
end

function Laser(entity_handle)
	if LocalPlayer.IsMining then return else LocalPlayer.IsMining = true end -- Stop players from doubling up the event
	if HaveItems('mininglaser') then
		-- Sounds & Anim Loading
		RequestAmbientAudioBank("DLC_HEIST_BIOLAB_DELIVER_EMP_SOUNDS", 0)
		RequestAmbientAudioBank("dlc_xm_silo_laser_hack_sounds", 0)
		local dict = "anim@heists@fleeca_bank@drilling"
		local anim = "drill_straight_fail"
		Anim.LoadDict(dict)
		--Create Drill and Attach
		local DrillObject = CreateObject(`ch_prop_laserdrill_01a`, GetEntityCoords(PlayerPedId(), true), true, true, true)
		AttachEntityToEntity(DrillObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0, -0.01, 90.0, -90.0, 180.0, true, true, false, true, 1, true)
		LocalPlayer.IsDrilling = true
		local rockcoords = GetEntityCoords(entity_handle)
		--Calculate if you're facing the stone--
		Entity.FaceToEntity(entity_handle)
		Entity.Prop.List[entity_handle] = false
		--Activation noise & Anims
		TaskPlayAnim(PlayerPedId(), tostring(dict), 'drill_straight_idle' , 3.0, 3.0, -1, 1, 0, false, false, false)
		PlaySoundFromEntity(soundId, "Pass", DrillObject, "dlc_xm_silo_laser_hack_sounds", 1, 0) Wait(1000)
		TaskPlayAnim(PlayerPedId(), tostring(dict), tostring(anim), 3.0, 3.0, -1, 1, 0, false, false, false)
		PlaySoundFromEntity(soundId, "EMP_Vehicle_Hum", DrillObject, "DLC_HEIST_BIOLAB_DELIVER_EMP_SOUNDS", 1, 0) --Not sure about this sound, best one I could find as everything else wouldn't load
		--Laser & Debris Effect
		local lasercoords = GetOffsetFromEntityInWorldCoords(DrillObject, 0.0,-0.5, 0.02)
		CreateThread(function()
			PTFX.LoadAsset("core")
			while LocalPlayer.IsDrilling do
				UseParticleFxAssetNextCall("core")
				local laser = StartNetworkedParticleFxNonLoopedAtCoord("muz_railgun", lasercoords.x, lasercoords.y, lasercoords.z, 0, -10.0, GetEntityHeading(DrillObject)+270, 1.0, 0.0, 0.0, 0.0)
				UseParticleFxAssetNextCall("core")
				local dust = StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_rocks", rockcoords.x, rockcoords.y, rockcoords.z, 0.0, 0.0, GetEntityHeading(PlayerPedId())-180.0, 1.0, 0.0, 0.0, 0.0)
				Wait(60)
			end
		end)

		exports['rprogress']:Custom({
			Label = "Mining...", 
			Duration = Config.Timings["Laser"],
			onComplete = function(cancelled)
				if not cancelled then
					LocalPlayer.IsDrilling = false
					LocalPlayer.IsMining = false
					StopAnimTask(PlayerPedId(), tostring(dict), tostring(anim), 1.0)
					ReleaseAmbientAudioBank("DLC_HEIST_BIOLAB_DELIVER_EMP_SOUNDS")
					ReleaseAmbientAudioBank("dlc_xm_silo_laser_hack_sounds")
					StopSound(soundId)
					Entity.Prop.Delete(DrillObject)
					PTFX.LoadAsset("core")
					Anim.LoadDict(dict)
					TriggerServerEvent('jim-mining:MineReward')
					StoneBreak(entity_handle)
				else
					LocalPlayer.IsDrilling = false
					LocalPlayer.IsMining = false
					StopAnimTask(PlayerPedId(), tostring(dict), tostring(anim), 1.0)
					ReleaseAmbientAudioBank("DLC_HEIST_BIOLAB_DELIVER_EMP_SOUNDS")
					ReleaseAmbientAudioBank("dlc_xm_silo_laser_hack_sounds")
					StopSound(soundId)
					Entity.Prop.Delete(DrillObject)
					PTFX.LoadAsset("core")
					Anim.LoadDict(dict)
					StoneBreak(entity_handle)
					LocalPlayer.IsDrilling = false
					LocalPlayer.IsMining = false
				end
			end
		})
	else
		ESX.ShowNotification('system', nil, "")
	end
end

function CrackStart(data)
	if LocalPlayer.IsCracking then return end
	if HaveItems("stone") then
		LocalPlayer.IsCracking = true
		-- Sounds & Anim Loading
		local dict ="amb@prop_human_parking_meter@male@idle_a"
		local anim = "idle_a"
		Anim.LoadDict(dict)
		Sound.Load()
		local closestObj, dist = ESX.Game.GetClosestObject(nil, {
			[GetHashKey('prop_vertdrill_01')] = true
		})
		if closestObj ~= -1 and dist <= 2.0 then
			local benchcoords = GetOffsetFromEntityInWorldCoords(closestObj, 0.0, -0.2, 2.08)
			--Calculate if you're facing the bench--
			Entity.FaceToEntity(closestObj)
			if #(benchcoords - GetEntityCoords(PlayerPedId())) > 1.5 then TaskGoStraightToCoord(PlayerPedId(), benchcoords, 0.5, 400, 0.0, 0) Wait(400) end

			local Rock = CreateObject(`prop_rock_5_smash1`, vector3(benchcoords.x, benchcoords.y, benchcoords.z-1.03), true, true, true)
			PlaySoundFromCoord(soundId, "Drill", benchcoords, "DLC_HEIST_FLEECA_SOUNDSET", 0, 4.5, 0)
			PTFX.LoadAsset("core")
			CreateThread(function()
				while LocalPlayer.IsCracking do
					UseParticleFxAssetNextCall("core")
					local dust = StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_rocks", benchcoords.x, benchcoords.y, benchcoords.z-0.9, 0.0, 0.0, 0.0, 0.2, 0.0, 0.0, 0.0)
					Wait(400)
				end
			end)
			TaskPlayAnim(PlayerPedId(), dict, anim, 3.0, 3.0, -1, 1, 0, false, false, false)

			exports['rprogress']:Custom({
				Label = "Cracking stone...", 
				Duration = Config.Timings["Cracking"],
				onComplete = function(cancelled)
					if not cancelled then
						StopAnimTask(PlayerPedId(), dict, anim, 1.0)
						Sound.Unload()
						StopSound(soundId)
						PTFX.LoadAsset("core")
						Anim.LoadDict(dict)
						TriggerServerEvent('jim-mining:CrackReward')
						Entity.Prop.Delete(Rock)
						LocalPlayer.IsCracking = false
					else
						StopAnimTask(PlayerPedId(), dict, anim, 1.0)
						Sound.Unload()
						StopSound(soundId)
						PTFX.LoadAsset("core")
						Anim.LoadDict(dict)
						Entity.Prop.Delete(Rock)
						LocalPlayer.IsCracking = false
					end
				end
			})
		end
	else
		-- triggerNotify(nil, Loc[Config.Lan].error["no_stone"], 'error')
		ESX.ShowNotification('system', nil, Loc[Config.Lan].error["no_stone"])
	end
end

function WashStart()
	if LocalPlayer.IsWashing then return end
	if HaveItems("stone") then
		LocalPlayer.IsWashing = true
		local Rock = CreateObject(`prop_rock_5_smash1`, GetEntityCoords(PlayerPedId()), true, true, true)
		local rockcoords = GetEntityCoords(Rock)
		AttachEntityToEntity(Rock, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.1, 0.0, 0.05, 90.0, -90.0, 90.0, true, true, false, true, 1, true)
		TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
		local water
		CreateThread(function()
			Wait(3000)
			PTFX.LoadAsset("core")
			while LocalPlayer.IsWashing do
				UseParticleFxAssetNextCall("core")
				water = StartNetworkedParticleFxLoopedOnEntity("water_splash_veh_out", PlayerPedId(), 0.0, 1.0, -0.2, 0.0, 0.0, 0.0, 2.0, 0, 0, 0)
				Wait(500)
			end
		end)
		exports['rprogress']:Custom({
			Label = 'Washing stone...',
			Duration = Config.Timings["Washing"],
			onComplete = function(cancelled)
				if not cancelled then
					TriggerServerEvent('jim-mining:WashReward')
					StopParticleFxLooped(water, 0)
					Entity.Prop.Delete(Rock)
					PTFX.UnloadAsset("core")
					LocalPlayer.IsWashing = false
					ClearPedTasksImmediately(PlayerPedId())
				else
					StopParticleFxLooped(water, 0)
					Entity.Prop.Delete(Rock)
					PTFX.UnloadAsset("core")
					LocalPlayer.IsWashing = false
					ClearPedTasksImmediately(PlayerPedId())
				end
			end
		})
	else
		-- triggerNotify(nil, Loc[Config.Lan].error["no_stone"], 'error')
	end
end

function PanStart(data)
	if IsEntityInWater(PlayerPedId()) then
		if LocalPlayer.IsPanning then return else LocalPlayer.IsPanning = true end
		local trayCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.5, -0.9)
		local PanningProp = Entity.Prop.Create({ coords = vector4(trayCoords.x, trayCoords.y, trayCoords.z+1.03, GetEntityHeading(PlayerPedId())), prop = `bkr_prop_meth_tray_01b`} , 1, 1)
		CreateThread(function()
			PTFX.LoadAsset("core")
			while LocalPlayer.IsPanning do
				UseParticleFxAssetNextCall("core")
				local water = StartNetworkedParticleFxLoopedOnEntity("water_splash_veh_out", PanningProp, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 0, 0, 0)
				Wait(100)
			end
		end)
		--Start Anim
		TaskStartScenarioInPlace(PlayerPedId(), "CODE_HUMAN_MEDIC_KNEEL", 0, true)
		exports['rprogress']:Custom({
			Label = Loc[Config.Lan].info["goldpanning"],
			Duration = Config.Timings["Panning"],
			onComplete = function(cancelled)
				if not cancelled then
					TriggerServerEvent('jim-mining:PanReward')
					ClearPedTasksImmediately(PlayerPedId())
					TaskGoStraightToCoord(PlayerPedId(), trayCoords, 4.0, 100, GetEntityHeading(PlayerPedId()), 0)
					Entity.Prop.Delete(PanningProp)
					PTFX.UnloadAsset("core")
					LocalPlayer.IsPanning = false
				else
					ClearPedTasksImmediately(PlayerPedId())
					TaskGoStraightToCoord(PlayerPedId(), trayCoords, 4.0, 100, GetEntityHeading(PlayerPedId()), 0)
					Entity.Prop.Delete(PanningProp)
					PTFX.UnloadAsset("core")
					LocalPlayer.IsPanning = false
				end
			end
		})
	end
end

function itemProgress(data)
	if data.craftable then
		if not data.ret then 
			bartext = Loc[Config.Lan].info["smelting"]
		else 
			bartext = Loc[Config.Lan].info["cutting"] 
		end
	end
	LocalPlayer.IsDrilling = true
	if data.ret then -- If jewelcutting
		local drillcoords
		local scene
		local dict = "anim@amb@machinery@speed_drill@"
		local anim = "operate_02_hi_amy_skater_01"
		Anim.LoadDict(dict)
		for _, v in pairs(Entity.Prop.List) do
			if #(GetEntityCoords(v) - GetEntityCoords(PlayerPedId())) <= 2.0 and GetEntityModel(v) == `gr_prop_gr_speeddrill_01c` then
				Sound.Load()
				PlaySoundFromEntity(soundId, "Drill", v, "DLC_HEIST_FLEECA_SOUNDSET", 0.5, 0)
				drillcoords = GetOffsetFromEntityInWorldCoords(v, 0.0, -0.15, 0.0)
				scene = NetworkCreateSynchronisedScene(GetEntityCoords(v), GetEntityRotation(v), 2, false, false, 1065353216, 0, 1.3)
				NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, tostring(dict), tostring(anim), 0, 0, 0, 16, 1148846080, 0)
				NetworkStartSynchronisedScene(scene)
				break
			end
		end
		CreateThread(function()
			PTFX.LoadAsset("core")
			while LocalPlayer.IsDrilling do
				UseParticleFxAssetNextCall("core")
				local dust = StartNetworkedParticleFxNonLoopedAtCoord("glass_side_window", drillcoords.x, drillcoords.y, drillcoords.z+1.1, 0.0, 0.0, GetEntityHeading(PlayerPedId())+math.random(0, 359), 0.2, 0.0, 0.0, 0.0)
				Wait(100)
			end
		end)
	else -- If not Jewel Cutting, you'd be smelting (need to work out what is possible for this)
		animDictNow = "amb@prop_human_parking_meter@male@idle_a"
		animNow = "idle_a"
	end

	exports['rprogress']:Custom({
		Label = bartext, 
		Duration = Config.Timings["Crafting"],
		onComplete = function(cancelled)
			if not cancelled then
				if data.ret then
					if math.random(1,10) >= 8 then
						local breakId = GetSoundId()
						PlaySoundFromEntity(breakId, "Drill_Pin_Break", PlayerPedId(), "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
						-- toggleItem(false, "drillbit", 1) -- REPLACE BY WORKING FUNCTION
					end
				end
				Sound.Unload()
				StopSound(soundId)
				PTFX.LoadAsset("core")
				isDrilling = false
				NetworkStopSynchronisedScene(scene)
			else
				triggerNotify(nil, Loc[Config.Lan].error["cancelled"], 'error')
				StopAnimTask(PlayerPedId(), animDictNow, animNow, 1.0)
				Sound.Unload()
				StopSound(soundId)
				PTFX.LoadAsset("core")
				Anim.LoadDict(dict)
				LocalPlayer.IsDrilling = false
				NetworkStopSynchronisedScene(scene)
			end
		end
	})
end