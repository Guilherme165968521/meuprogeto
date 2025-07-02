-- 'bolt_pedselector' by Bolt
-- Script do lado do cliente que gerencia a lógica do painel.

local display = false
local vRP = Proxy.getInterface("vRP")
local DwarfServer = Tunnel.getInterface("bolt_pedselector")

-- Função para mostrar/esconder o painel
local function setDisplay(show)
    display = show
    SetNuiFocus(show, show)
    SendNUIMessage({
        type = "ui",
        status = show
    })
end

-- Registra o comando /peds para abrir/fechar o painel
RegisterCommand('peds', function(source, args, rawCommand)
    if not display then
        -- Pede a lista de peds ao servidor antes de abrir
        CreateThread(function()
            local peds = DwarfServer.getDwarfs()
            SendNUIMessage({
                type = "setup",
                peds = peds
            })
            setDisplay(true)
        end)
    else
        setDisplay(false)
    end
end, false)

-- Callback para quando um ped comprado é selecionado na UI
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

-- Callback para comprar um ped
RegisterNUICallback('buyPed', function(data, cb)
    local dwarfId = data.id
    if not dwarfId then return end
    TriggerServerEvent('bolt_pedselector:buyDwarf', dwarfId)
    cb({ ok = true })
end)

-- Callback para testar um ped
RegisterNUICallback('testPed', function(data, cb)
    local model = data.model
    if not model then return end
    TriggerServerEvent('bolt_pedselector:testDwarf', model)
    setDisplay(false) -- Fecha o painel para o teste
    cb({ ok = true })
end)

-- Callback para fechar o painel (via tecla ESC na UI)
RegisterNUICallback('close', function(data, cb)
    setDisplay(false)
    cb({ ok = true })
end)

-- Evento para aplicar uma skin temporária (vinda do servidor)
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

-- Evento para atualizar a UI após uma compra bem-sucedida
RegisterNetEvent('bolt_pedselector:purchaseSuccess', function(dwarfId)
    if display then
        SendNUIMessage({
            type = "updatePedStatus",
            id = dwarfId,
            purchased = true
        })
    end
end)
