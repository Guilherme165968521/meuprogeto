-- 'bolt_pedselector' by Bolt
-- Este é o manifesto do recurso, que define os arquivos e metadados.

fx_version 'cerulean'
game 'gta5'

author 'Bolt'
description 'Um painel moderno para seleção de peds com integração vRP, criado por Bolt.'
version '1.1.0'

-- Define a página da UI
ui_page 'html/index.html'

-- Arquivos que a UI precisa acessar
files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

-- Scripts compartilhados, de cliente e de servidor
shared_script 'config.lua'
client_script 'client/client.lua'
server_script 'server/server.lua'

-- Dependências essenciais para vRP e oxmysql
dependency 'vRP'
dependency 'oxmysql'

shared_script '@vRP/lib/utils.lua'
server_script '@oxmysql/lib/MySQL.lua'

lua54 'yes'
