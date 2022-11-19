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

function Entity.Prop.Create(data, freeze, synced)
    Model.Load(data.prop)
    -- data.coords = vector3(data.coords.x, data.coords.y, data.coords.z-1.03)
    local entity_handle = CreateObject(data.prop, data.coords.x, data.coords.y, data.coords.z-1.03, synced or false, synced or false, 0)
    SetEntityHeading(entity_handle, data.coords.w+180.0)
    FreezeEntityPosition(entity_handle, freeze or 0)
    table.insert(Entity.Prop.List, entity_handle)
    return entity_handle
end

function Entity.Prop.Delete(entity_handle)
    if Entity.Exist(entity_handle) then
        SetEntityAsMissionEntity(entity) 
        Wait(5)
        DetachEntity(entity, true, true) 
        Wait(5)
        DeleteObject(entity)
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

function Entity.Error(msg)
    print('[^3ENTITY^7] '..msg) 
end