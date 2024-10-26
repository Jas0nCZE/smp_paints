fx_version 'cerulean'
game 'gta5'

author 'S1MPLE Resources'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}



server_script 'server.lua'

dependencies {
    'ox_lib',
}