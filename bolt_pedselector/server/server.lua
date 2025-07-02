-- 'bolt_pedselector' by Bolt
-- Script do lado do servidor com lógica vRP e oxmysql.

-- Inicia o proxy do vRP para comunicação segura com o cliente
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
DwarfServer = {}
Tunnel.bindInterface("bolt_pedselector", DwarfServer)

-- Função para obter o identificador do jogador (ex: license)
function getPlayerIdentifier(source)
    local user_id = vRP.getUserId({source})
    if user_id then
        local identity = vRP.getUserIdentity({user_id})
        if identity and identity.license then
            return "license:" .. identity.license
        end
    end
    return nil
end

-- Função exposta ao cliente para buscar a lista de anões
function DwarfServer.getDwarfs()
    local source = source
    local identifier = getPlayerIdentifier(source)
    if not identifier then return {} end

    -- Prepara a query para buscar todos os anões e marcar os que o jogador já possui
    local query = [[
        SELECT
            d.id,
            d.name,
            d.model,
            d.image_url,
            d.price,
            CASE WHEN pd.id IS NOT NULL THEN true ELSE false END AS purchased
        FROM dwarfs d
        LEFT JOIN player_dwarfs pd ON d.id = pd.dwarf_id AND pd.player_identifier = ?
    ]]

    -- Executa a query usando o sistema do vRP/oxmysql
    local result = MySQL.query.await(query, {identifier})
    return result or {}
end

-- Evento para comprar um anão
RegisterNetEvent('bolt_pedselector:buyDwarf', function(dwarfId)
    local source = source
    local user_id = vRP.getUserId({source})
    local identifier = getPlayerIdentifier(source)

    if not user_id or not identifier or not dwarfId then return end

    -- 1. Busca o preço do anão e verifica se o jogador já o possui
    local dwarfQuery = "SELECT price FROM dwarfs WHERE id = ?"
    local ownedQuery = "SELECT id FROM player_dwarfs WHERE player_identifier = ? AND dwarf_id = ?"

    local dwarfResult = MySQL.query.await(dwarfQuery, {dwarfId})
    local ownedResult = MySQL.query.await(ownedQuery, {identifier, dwarfId})

    if not dwarfResult or #dwarfResult == 0 then
        -- Anão não encontrado
        TriggerClientEvent('chat:addMessage', source, { args = {"^1[SISTEMA]", "Este ped não está à venda."} })
        return
    end

    if ownedResult and #ownedResult > 0 then
        -- Jogador já possui o anão
        TriggerClientEvent('chat:addMessage', source, { args = {"^1[SISTEMA]", "Você já possui este ped."} })
        return
    end

    local price = dwarfResult[1].price

    -- 2. Tenta efetuar o pagamento
    if vRP.tryPayment({user_id, price}) then
        -- 3. Se o pagamento for bem-sucedido, insere o registro da compra
        local insertQuery = "INSERT INTO player_dwarfs (player_identifier, dwarf_id) VALUES (?, ?)"
        MySQL.execute.await(insertQuery, {identifier, dwarfId})

        TriggerClientEvent('chat:addMessage', source, { args = {"^2[SISTEMA]", "Ped comprado com sucesso!"} })
        -- Notifica a UI para atualizar o estado (opcional, mas recomendado)
        TriggerClientEvent('bolt_pedselector:purchaseSuccess', source, dwarfId)
    else
        -- Saldo insuficiente
        TriggerClientEvent('chat:addMessage', source, { args = {"^1[SISTEMA]", "Você não tem coins suficientes."} })
    end
end)

-- Evento para testar um anão
RegisterNetEvent('bolt_pedselector:testDwarf', function(pedModel)
    local source = source
    -- Lógica de teste (ex: aplicar skin por 5 minutos)
    -- Por enquanto, apenas aplica a skin no cliente.
    -- No futuro, pode-se adicionar um timer aqui.
    TriggerClientEvent('bolt_pedselector:applyTempSkin', source, pedModel)
    TriggerClientEvent('chat:addMessage', source, { args = {"^3[SISTEMA]", "Você está testando um novo ped. Ele voltará ao normal em breve."} })
end)
