-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

description 'Admin Item Giver'
author 'ii_abual3bed | stdev'

lua54 'yes'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
    'translations/app.js'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
