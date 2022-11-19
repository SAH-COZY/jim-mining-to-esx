Blip = {}
Blip.List = {}

function Blip.Create(data)
	print("BLIP.CREATE:  "..json.encode(data))
    blip = AddBlipForCoord(data.coords)
	SetBlipAsShortRange(blip, true)
	SetBlipSprite(blip, data.sprite or 1)
	SetBlipColour(blip, data.col or 0)
	SetBlipScale(blip, data.scale or 0.7)
	SetBlipDisplay(blip, (data.disp or 6))
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString(tostring(data.name))
	EndTextCommandSetBlipName(blip)
    Blip.List[blip] = true
	return blip
end

function Blip.Remove(id)
	RemoveBlip(id)
	if Blip.List[id] then
		Blip.List[id] = nil
		return true
	end
	return false
end