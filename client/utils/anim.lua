Anim = {}

function Anim.LoadDict(dict_name)
    if DoesAnimDictExist(dict_name) then
        local prev_inf_timeout = 5000
        RequestAnimDict(dict_name)
        while not HasAnimDictLoaded(dict_name) do 
            prev_inf_timeout = prev_inf_timeout-1 
            if prev_inf_timeout < 1 then  
                Anim.Error("Cannot load animation dictionnary in memory")
                return false
            end
            Wait(1) 
        end
    else
        Anim.Error("Animation dictionnary does'nt exist in game/server files")
    end
end

function Anim.UnloadDict(dict_name)
    if DoesAnimDictExist(dict_name) then
        RemoveAnimDict(dict_name)
    else
        Anim.Error("Animation dictionnary does'nt exist in game/server files")
    end
end

function Anim.Error(msg)
    print('[^3ANIM^7] '..msg)
end