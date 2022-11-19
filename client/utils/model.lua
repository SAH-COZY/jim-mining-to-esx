Model = {}

function Model.Load(model)
    print('in model load: '..model)
    if type(model) == 'string' then model = GetHashKey(model) end
    if IsModelInCdimage(model) then
        local prev_inf_timeout = 5000
        RequestModel(model)
        while not HasModelLoaded(model) do 
            prev_inf_timeout = prev_inf_timeout-1 
            if prev_inf_timeout < 1 then  
                Model.Error("Cannot load model in memory")
                return false
            end
            Wait(1) 
        end
        return true
    else
        Model.Error("Model does'nt exist in game/server files")
    end
end

function Model.Unload(model)
    if type(model) == 'string' then model = GetHashKey(model) end
    if IsModelInCdimage(model) then
        SetModelAsNoLongerNeeded(model)
    end
end

function Model.Error(msg)
    print('[^3MODELS^7] '..msg)
end