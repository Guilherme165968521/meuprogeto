-- 'bolt_pedselector' by Bolt
-- Script do lado do cliente que gerencia a lógica do painel.

local display = false

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
    -- Apenas envia a lista de peds se o painel estiver fechado e prestes a abrir
    if not display then
        SendNUIMessage({
            type = "setup",
            peds = Config.Peds
        })
    end
    setDisplay(not display)
end, false) -- 'false' permite que qualquer jogador use o comando

-- Callback para quando um ped é selecionado na UI
RegisterNUICallback('selectPed', function(data, cb)
    local model = data.model
    if not model then return end

    -- Lógica para trocar o modelo do jogador
    CreateThread(function()
        local modelHash = GetHashKey(model)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(100)
        end
        SetPlayerModel(PlayerId(), modelHash)
        SetModelAsNoLongerNeeded(modelHash)
    end)

    -- Fecha o painel após a seleção
    setDisplay(false)
    cb({ ok = true })
end)

-- Callback para fechar o painel (via tecla ESC na UI)
RegisterNUICallback('close', function(data, cb)
    setDisplay(false)
    cb({ ok = true })
end)
