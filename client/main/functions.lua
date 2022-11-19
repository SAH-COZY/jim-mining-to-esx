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
				local prop_rock_2 = Entity.Prop.Create({coords = vector4(v.x, v.y, v.z+0.25, v[4]), prop = `prop_rock_5_a`}, 1, false)
			end
		else 
			Config.K4MB1 = true 
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
				if dist <= 10.0 then
					if Entity.Prop.List[v] then
						interval = 1
						if dist <= 2.0 then
							local curr_prop_data = InteractionsByPropModel[tostring(GetEntityModel(v))]
							ESX.ShowHelpNotification(curr_prop_data.help_text)
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
								ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to interact with ped')
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
							ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to interact')
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

function itemProgress(data)
	if data.craftable then
		if not data.ret then 
			bartext = Loc[Config.Lan].info["smelting"]--[[..QBCore.Shared.Items[data.item].label]]
		else 
			bartext = Loc[Config.Lan].info["cutting"] 
		end
	end
	-- LocalPlayer.state:set("inv_busy", true, true) TriggerEvent('inventory:client:busy:status', true) TriggerEvent('canUseInventoryAndHotbar:toggle', false)
	local isDrilling = true
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
				isDrilling = false
				NetworkStopSynchronisedScene(scene)
			end
		end
	})
end

function StoneBreak(stone)
	local rockcoords = GetEntityCoords(stone)
	--Stone CoolDown + Recreation
	SetEntityAlpha(stone, 0)
	Entity.Prop.List[stone] = false
	SetTimeout(Config.Timings["OreRespawn"], function()
		SetEntityAlpha(stone, 255)
		Entity.Prop.List[stone] = true
	end)
	--CreateModelHide(rockcoords, 1.0, `cs_x_rubweec`, true)
	--Unhide Stone and create a new target location
	-- SetEntityAlpha(stone, 255)
	--RemoveModelHide(rockcoords, 1.0, `cs_x_rubweec`, true)
end