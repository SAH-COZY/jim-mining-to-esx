ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('jim-mining:HaveItems', function(src, cb, items)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer.getJob().name == 'miner' then
        if type(items) == 'table' then
            for k,v in pairs(items) do
                if xPlayer.getInventoryItem(v).count < 1 then
                    cb(false)
                end
            end
            cb(true)
        elseif type(items) == 'string' then
            if xPlayer.getInventoryItem(items).count > 0 then
                cb(true)
            else
                cb(false)
            end
        end
    end
end)

ESX.RegisterServerCallback('jim-mining:GetPlayerBestTool', function(src, cb)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer.getJob().name == 'miner' then
        for _,tool in pairs({'mininglaser', 'miningdrill', 'pickaxe'}) do
            if xPlayer.getInventoryItem(tool).count > 0 then
                print('Returning tool named '..tool)
                cb(tool)
            end
        end
    end
end)