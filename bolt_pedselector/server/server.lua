-- 'bolt_pedselector' by Bolt
-- v2.0.0: Versão funcional com sistema de compra e teste.

local Tunnel = module("lib/Tunnel")
local vRP = Tunnel.getInterface("vRP")

-- Função segura para obter o identificador do jogador, com logs de erro.
function getPlayerIdentifier(source)
    local p, identifier = pcall(function()
        local user_id = vRP.getUserId({source})
        if not user_id then
            print("[bolt_pedselector] [SERVER] ERRO: vRP.getUserId retornou nulo.")
            return nil
        end

        local identity = vRP.getUserIdentity({user_id})
        if not identity or not identity.license then
            print("[bolt_pedselector] [SERVER] ERRO: vRP.getUserIdentity não retornou uma identidade ou licença válida.")
            return nil
        end

        return "license:" .. identity.license
    end)

    if not p then
        print(("[bolt_pedselector] [SERVER] ERRO CRÍTICO em getPlayerIdentifier: %s"):format(tostring(identifier)))
        return nil
    end

    return identifier
end

RegisterNetEvent('bolt_pedselector:getDwarfs', function()
    local source = source
    local identifier = getPlayerIdentifier(source)

    if not identifier then
        print("[bolt_pedselector] [SERVER] AVISO: Identificador não encontrado. O painel não será aberto.")
        vRP.notify(source, "~r~Não foi possível carregar seus dados. Tente novamente.")
        TriggerClientEvent('bolt_pedselector:receiveDwarfs', source, {})
        return
    end

    local query = [[
        SELECT
            d.id,
            d.name,
            d.model,
            d.image_url,
            d.price,
            CASE WHEN pd.id IS NOT NULL THEN 1 ELSE 0 END AS purchased
        FROM dwarfs d
        LEFT JOIN player_dwarfs pd ON d.id = pd.dwarf_id AND pd.player_identifier = ?
    ]]

    local success, result = pcall(function()
        return MySQL.query.await(query, {identifier})
    end)

    if not success then
        print(("[bolt_pedselector] [SERVER] ERRO na consulta SQL: %s"):format(tostring(result)))
        vRP.notify(source, "~r~Erro ao carregar a lista de peds.")
        TriggerClientEvent('bolt_pedselector:receiveDwarfs', source, {})
        return
    end

    if result then
        for i, ped in ipairs(result) do
            ped.purchased = (ped.purchased == 1)
        end
    end

    TriggerClientEvent('bolt_pedselector:receiveDwarfs', source, result or {})
end)

RegisterNetEvent('bolt_pedselector:buyDwarf', function(dwarfId)
    local source = source
    local user_id = vRP.getUserId({source})
    local identifier = getPlayerIdentifier(source)

    if not user_id or not identifier or not dwarfId then return end

    local ownedQuery = "SELECT id FROM player_dwarfs WHERE player_identifier = ? AND dwarf_id = ?"
    local ownedResult = MySQL.query.await(ownedQuery, {identifier, dwarfId})

    if ownedResult and #ownedResult > 0 then
        vRP.notify(source, "~r~Você já possui este ped.")
        return
    end

    local dwarfQuery = "SELECT price FROM dwarfs WHERE id = ?"
    local dwarfResult = MySQL.query.await(dwarfQuery, {dwarfId})

    if not dwarfResult or #dwarfResult == 0 then
        vRP.notify(source, "~r~Este ped não está à venda.")
        return
    end

    local price = dwarfResult[1].price

    if vRP.tryPayment({user_id, price}) then
        local insertQuery = "INSERT INTO player_dwarfs (player_identifier, dwarf_id) VALUES (?, ?)"
        MySQL.execute.await(insertQuery, {identifier, dwarfId})

        vRP.notify(source, "~g~Ped comprado com sucesso!")
        TriggerClientEvent('bolt_pedselector:purchaseSuccess', source, dwarfId)
    else
        vRP.notify(source, "~r~Você não tem coins suficientes.")
    end
end)

RegisterNetEvent('bolt_pedselector:testDwarf', function(pedModel)
    local source = source
    TriggerClientEvent('bolt_pedselector:applyTempSkin', source, pedModel)
    vRP.notify(source, "~y~Você está testando um novo ped. Ele voltará ao normal em breve.")
end)
