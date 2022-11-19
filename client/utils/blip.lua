Blip = {}
Blip.List = {}

function Blip.Create(data)
    local blip = AddBlipForCoord(data.coords)
	SetBlipAsShortRange(blip, true)
	SetBlipSprite(blip, data.sprite or 1)
	SetBlipColour(blip, data.col or 0)
	SetBlipScale(blip, data.scale or 0.7)
	SetBlipDisplay(blip, (data.disp or 6))
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString(tostring(data.name))
	EndTextCommandSetBlipName(blip)
    data.handle = blip
    table.insert(Blip.List, data)
	return blip
end

function Blip.Remove(id)
	RemoveBlip(id)
	for i,v in ipairs(Blip.List) do 
		if v == id then 
			table.remove(Blip.List, i) return true 
		end
	end
	return false
end