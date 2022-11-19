PTFX = {}

function PTFX.LoadAsset(asset)
    RequestNamedPtfxAsset(asset)
    while not HasNamedPtfxAssetLoaded(asset) do
        Wait(1)
    end
    return true
end

function PTFX.UnloadAsset(asset)
    RemoveNamedPtfxAsset(dict)
    return true
end