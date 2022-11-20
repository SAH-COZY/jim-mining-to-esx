RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	InitJobSpecs()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
	PlayerData = ESX.GetPlayerData()
	while not PlayerData.job do Wait(100) end
	InitJobSpecs()
end)

RegisterNetEvent('jim-mining:SellAnim', function(data)
	-- if not HasItem(data.item, 1) then triggerNotify(nil, Loc[Config.Lan].error["dont_have"].." "..QBCore.Shared.Items[data.item].label, "error") return end
	Anim.LoadDict("mp_common")
	TriggerServerEvent('jim-mining:Selling', data)
	Entity.FaceToEntity(data.ped)
	TaskPlayAnim(PlayerPedId(), "mp_common", "givetake2_a", 100.0, 200.0, 0.3, 1, 0.2, 0, 0, 0)	--Start animations
	TaskPlayAnim(data.ped, "mp_common", "givetake2_b", 100.0, 200.0, 0.3, 1, 0.2, 0, 0, 0)
	Wait(2000)
	StopAnimTask(PlayerPedId(), "mp_common", "givetake2_a", 1.0)
	StopAnimTask(data.ped, "mp_common", "givetake2_b", 1.0)
	Anim.UnloadDict("mp_common")
	if data.sub then TriggerEvent('jim-mining:JewelSell:Sub', { sub = data.sub, ped = data.ped }) return
	else TriggerEvent('jim-mining:SellOre', data) return end
end)

RegisterNetEvent('jim-mining:CraftMenu', function(data)
	Menu.OpenCraftMenu()
end)

RegisterNetEvent('jim-mining:SellOre', function(data)
	Menu.OpenSellOreMenu()
end)
------------------------

RegisterNetEvent('jim-mining:JewelSell', function(data)
	Menu.OpenSellJewelMenu()
end)
--Jewel Selling - Sub Menu Controller
RegisterNetEvent('jim-mining:JewelSell:Sub', function(data)
	Menu.OpenSellVangelicoMenu()
end)

--Cutting Jewels
RegisterNetEvent('jim-mining:JewelCut', function()
	Menu.OpenCraftMenu()
end)

RegisterNetEvent('jim-mining:MakeItem', function(data)
	if data.ret then
		if not HaveItems("drillbit") then 
			triggerNotify(nil, Loc[Config.Lan].error["no_drillbit"], 'error')
			TriggerEvent('jim-mining:JewelCut') 
			return
		end
	end
	itemProgress(data)
end)

AddEventHandler('onResourceStop', function(resource) if resource == GetCurrentResourceName() then RemoveJobSpecs() end end)