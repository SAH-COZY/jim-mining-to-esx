function pairsByKeys(t)
	local a = {}
	for n in pairs(t) do a[#a+1] = n end
	table.sort(a)
	local i = 0
	local iter = function() i = i + 1 if a[i] == nil then return nil else return a[i], t[a[i]] end end
	return iter
end

function countTable(table) 
    local c = 0 
    for _ in pairs(table) do 
        c = c + 1 
    end 
    return c
end

function triggerNotify(title, message, _type, src)
	if Config.Notify == "okok" then
		if not src then	exports['okokNotify']:Alert(title, message, 6000, _type)
		else TriggerClientEvent('okokNotify:Alert', src, title, message, 6000, _type) end
	elseif Config.Notify == "esx" then
		if not src then	TriggerEvent("esx:showNotification", _type, title, message)
		else TriggerClientEvent("esx:showNotification", src, _type, title, message) end
	elseif Config.Notify == "t" then
		if not src then exports['t-notify']:Custom({title = title, style = _type, message = message, sound = true})
		else TriggerClientEvent('t-notify:client:Custom', src, { style = _type, duration = 6000, title = title, message = message, sound = true, custom = true}) end
	elseif Config.Notify == "infinity" then
		if not src then TriggerEvent('infinity-notify:sendNotify', message, _type)
		else TriggerClientEvent('infinity-notify:sendNotify', src, message, _type) end
	elseif Config.Notify == "rr" then
		if not src then exports.rr_uilib:Notify({msg = message, type = _type, style = "dark", duration = 6000, position = "top-right", })
		else TriggerClientEvent("rr_uilib:Notify", src, {msg = message, type = _type, style = "dark", duration = 6000, position = "top-right", }) end
	end
end