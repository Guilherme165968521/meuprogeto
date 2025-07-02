-- Arquivo de Configuração para o 'bolt_pedselector'
-- Aqui você pode personalizar as configurações do script.

Config = {}

-- Tecla para abrir o painel.
-- Você pode encontrar os códigos das teclas aqui: https://docs.fivem.net/docs/game-references/controls/
Config.OpenKey = 322 -- Padrão: F8 (teclado) / INPUT_REPLAY_START_STOP_RECORDING_SECONDARY

-- Lista de Peds disponíveis para seleção.
-- 'name' é o que aparece no painel.
-- 'model' é o nome do modelo do ped no jogo.
Config.Peds = {
    { name = 'Policial', model = 's_m_y_cop_01' },
    { name = 'Paramédico', model = 's_m_y_paramedic_01' },
    { name = 'Bombeiro', model = 's_m_y_fireman_01' },
    { name = 'Skater', model = 'a_m_y_skater_01' },
    { name = 'Empresário', model = 'a_m_y_business_02' },
    { name = 'Praiano', model = 'a_m_m_beach_01' },
    { name = 'Fazendeiro', model = 'a_m_m_farmer_01' },
    { name = 'Gângster', model = 'g_m_y_ballaeast_01' },
    { name = 'Zumbi', model = 'u_m_y_zombie_01' },
}
