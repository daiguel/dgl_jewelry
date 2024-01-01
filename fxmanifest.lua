fx_version 'cerulean'
game 'gta5'

author 'Loureiro#0111'

description 'Jewelty Robbery - Stoned Scripts'

version '1.1'

shared_scripts {
	'@ox_lib/init.lua',
    'config/config.lua',
	'config/functions.lua',
	'locales/locale.lua',
    'locales/translations/*.lua'
}

server_scripts {
	'server/server.lua',
	'config/svconfig.lua'
}

client_scripts {
	'@mka-lasers/client/client.lua',
	'client/client.lua'
}

escrow_ignore {
    'config/config.lua',
	'config/functions.lua',
    'locales/translations/*.lua'
}

lua54 'yes'
