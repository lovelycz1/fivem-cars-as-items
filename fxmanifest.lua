fx_version 'cerulean'
game 'gta5'

description 'Cars as items'
author 'Lovely <3'
version '1.0.3'

shared_script {
    -- '@ox_lib/init.lua', -- remove "--" this if you are planning to use any ox scripts (such as ox notify)
    'config/config.lua',
    'config/framework.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

lua54 'yes'
