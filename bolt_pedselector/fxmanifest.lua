-- 'bolt_pedselector' by Bolt
-- Este é o manifesto do recurso, que define os arquivos e metadados.

fx_version 'cerulean'
game 'gta5'

author 'Bolt'
description 'Um painel moderno para seleção de peds com integração vRP, criado por Bolt.'
version '2.0.0' -- Versão funcional completa

-- Define a página da UI
ui_page 'html/index.html'

-- Arquivos que a UI precisa acessar
files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

-- Scripts compartilhados, de cliente e de servidor
shared_script '@vRP/lib/utils.lua'
client_script 'client/client.lua'
server_script 'server/server.lua'

-- Dependências essenciais
dependency 'vrp'
dependency 'oxmysql'

lua54 'yes'
