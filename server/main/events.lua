RegisterServerEvent('jim-mining:MineReward', function() -- FAIT
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getJob().name == 'miner' then
		math.randomseed(os.time())
		local randomChance = math.random(1, 3)
		xPlayer.addInventoryItem('stone', randomChance)
	end
end)

RegisterServerEvent('jim-mining:CrackReward', function() -- FAIT
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getJob().name == 'miner' then
		if xPlayer.getInventoryItem('stone').count > 0 then
			xPlayer.removeInventoryItem('stone', 1)
			for i = 1, math.random(1,3) do
				local randItem = Config.CrackPool[math.random(1, #Config.CrackPool)]
				amount = math.random(1, 2)
				if xPlayer.canCarryItem(randItem, amount) then
					xPlayer.addInventoryItem(randItem, amount)
				end
			end
		end
	end
end)

RegisterServerEvent('jim-mining:WashReward', function()
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getJob().name == 'miner' then
		xPlayer.removeInventoryItem('stone', 1)
		for i = 1, math.random(1,2) do
			local randItem = Config.WashPool[math.random(1, #Config.WashPool)]
			if xPlayer.canCarryItem(randItem, 1) then
				xPlayer.addInventoryItem(randItem, 1)
			end
		end
	end
end)

RegisterServerEvent('jim-mining:PanReward', function()
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getJob().name == 'miner' then
        xPlayer.removeInventoryItem('stone', 1)
        for i = 1, math.random(1,3) do
            local randItem = Config.PanPool[math.random(1, #Config.PanPool)]
            if xPlayer.canCarryItem(randItem, 1) then 
                xPlayer.addInventoryItem(randItem, 1)
            end
        end
    end
end)

RegisterNetEvent("jim-mining:Selling", function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.getJob().name == 'miner' then
        if xPlayer.getInventoryItem(data.item).count > 0 then
            local amount = xPlayer.getInventoryItem(data.item).count
            xPlayer.removeInventoryItem(data.item, amount)
            xPlayer.addMoney((amount * Config.SellItems[data.item]))
        else
            TriggerClientEvent("esx:showNotification", src, 'system', nil, Loc[Config.Lan].error["dont_have"].." "..ESX.GetItemLabel(data.item)) -- CHANGE
        end
    end
end)