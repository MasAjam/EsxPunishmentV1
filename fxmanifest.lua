fx_version 'cerulean'
game 'gta5'

author 'NATAKENSHI DEVELOPMENT'
description 'PUNISHMENT NYAPU TAMKOT'
version '1.2'

shared_scripts {
    '@es_extended/imports.lua'
}

server_scripts {
    '@es_extended/locale.lua',
    'server.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'client.lua'
}

dependencies {
    'es_extended'
}
