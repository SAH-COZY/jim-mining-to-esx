Entity = {}
Entity.Prop = {}
Entity.Prop.List = {}
Entity.Ped = {}
Entity.Ped.List = {}
Entity.Ped.Actions = {}

function Entity.Exist(entity)
    if DoesEntityExist(entity) then
        return true
    else
        Entity.Error("Entity doesn't exist")
        return false
    end
end

function Entity.FaceToCoords(coords)
    local playerPed = PlayerPedId()
    if not IsPedHeadingTowardsPosition(playerPed, coords.x, coords.y, coords.z, 10.0) then
        TaskTurnPedToFaceCoord(playerPed, coords.x, coords.y, coords.z, 1500)
        Wait(1500)
    end
end

function Entity.FaceToEntity(entity)
    local playerPed = PlayerPedId()
    if DoesEntityExist(entity) then
        if not IsPedHeadingTowardsPosition(PlayerPedId(), GetEntityCoords(entity), 30.0) then
            TaskTurnPedToFaceCoord(PlayerPedId(), GetEntityCoords(entity), 1500)
            Wait(1500)
        end
    end
end

function Entity.IsVisible(entity_handle)
    return (GetEntityAlpha(entity_handle)>0)
end

function Entity.Prop.Create(data, freeze, synced)
    Model.Load(data.prop)
    if not DoesObjectOfTypeExistAtCoords(data.coords.x, data.coords.y, data.coords.z, 1.0, data.prop, 0) then
        local entity_handle = CreateObject(data.prop, data.coords.x, data.coords.y, data.coords.z-1.03, synced or false, synced or false, 0)
        SetEntityHeading(entity_handle, data.coords.w+180.0)
        FreezeEntityPosition(entity_handle, freeze or 0)
        Entity.Prop.List[entity_handle] = true
        return entity_handle
    else
        Entity.Error("There's already an object with this model at these coords, adding it to data table...")
        local _model = data.prop
        Entity.Error("Prop already exist, trying to get handle...")
        if type(_model) == 'string' then _model = GetHashKey(_model) end
        local closestObj, dist = ESX.Game.GetClosestObject(data.coords, {
            [_model] = true
        })
        Entity.Error('Checking result: Handle = '..tostring(closestObj).." Distance = "..tostring(dist))
        if closestObj ~= -1 and dist <= 1.5 then
            Entity.Prop.List[closestObj] = true
        end
    end
end

function Entity.Prop.Delete(entity_handle)
    if Entity.Exist(entity_handle) then
        SetEntityAsNoLongerNeeded(entity_handle) 
        DetachEntity(entity_handle, true, true) 
        DeleteObject(entity_handle)
        Entity.Prop.List[entity_handle] = nil
    end
end

function Entity.Ped.Create(model, coords, freeze, collision, scenario, anim, action)
    Model.Load(model)
    local ped = CreatePed(0, model, coords.x, coords.y, coords.z-1.03, coords.w, false, false)
    SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, freeze or true)
    if collision then SetEntityNoCollisionEntity(ped, PlayerPedId(), false) end
    if scenario then TaskStartScenarioInPlace(ped, scenario, 0, true) end
    if anim then
        Anim.LoadDict(anim[1])
        TaskPlayAnim(ped, anim[1], anim[2], 1.0, 1.0, -1, 1, 0.2, 0, 0, 0)
    end
    Entity.Ped.List[ped] = ped
    if action then
        Entity.Ped.Actions[ped] = action
    end
	return ped
end

function Entity.FadeOut(entity)
    for i = 255, 0, -1 do
        SetEntityAlpha(entity, i, true)
        Wait(10)
    end
end

function Entity.FadeIn(entity)
    for i = 0, 255, 1 do
        SetEntityAlpha(entity, i, true)
        Wait(10)
    end
end

function Entity.Error(msg)
    print('[^3ENTITY^7] '..msg) 
end