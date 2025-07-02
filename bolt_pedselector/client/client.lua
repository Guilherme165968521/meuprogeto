-- 'bolt_pedselector' by Bolt
-- v2.0.0: Versão funcional com todos os callbacks da UI.

local display = false

local function setDisplay(show)
    display = show
    SetNuiFocus(show, show)
    SendNUIMessage({
        type = "ui",
        status = show
    })
end

RegisterCommand('peds', function()
    if not display then
        TriggerServerEvent('bolt_pedselector:getDwarfs')
    else
        setDisplay(false)
    end
end, false)

RegisterNetEvent('bolt_pedselector:receiveDwarfs', function(peds)
    if not peds or #peds == 0 and not display then
        -- Não abre a UI se não houver peds, a menos que já esteja aberta para fechar.
        return
    end
    SendNUIMessage({
        type = "setup",
        peds = peds
    })
    setDisplay(true)
end)

RegisterNUICallback('selectPed', function(data, cb)
    local model = data.model
    if not model then return end

    CreateThread(function()
        local modelHash = GetHashKey(model)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(100)
        end
        SetPlayerModel(PlayerId(), modelHash)
        SetModelAsNoLongerNeeded(modelHash)
    end)

    setDisplay(false)
    cb({ ok = true })
end)

RegisterNUICallback('buyPed', function(data, cb)
    local dwarfId = data.id
    if not dwarfId then return end
    TriggerServerEvent('bolt_pedselector:buyDwarf', dwarfId)
    cb({ ok = true })
end)

RegisterNUICallback('testPed', function(data, cb)
    local model = data.model
    if not model then return end
    TriggerServerEvent('bolt_pedselector:testDwarf', model)
    setDisplay(false)
    cb({ ok = true })
end)

RegisterNUICallback('close', function(data, cb)
    setDisplay(false)
    cb({ ok = true })
end)

RegisterNetEvent('bolt_pedselector:applyTempSkin', function(pedModel)
    CreateThread(function()
        local modelHash = GetHashKey(pedModel)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(100)
        end
        SetPlayerModel(PlayerId(), modelHash)
        SetModelAsNoLongerNeeded(modelHash)
    end)
end)

RegisterNetEvent('bolt_pedselector:purchaseSuccess', function(dwarfId)
    if display then
        SendNUIMessage({
            type = "updatePedStatus",
            id = dwarfId
        })
    end
end)
