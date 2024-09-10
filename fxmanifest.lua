fx_version 'bodacious'
games { 'gta5' }

author "azutake"
description "Converted to ESX by AP (https://github.com/apfrmeast/az-stance)"

ui_page "html/index.html"
-- ui_page "https://devfront-stance.vrcgta.jp"

files {
	"html/*",
	"html/assets/*.js",
	"html/assets/*.css",
	"locales/*.json"
}

client_scripts {
	"localize-core.lua",
	"localize.lua",
	"client.lua"
}

shared_scripts {
	'config.lua'
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"server.lua",
	
}

dependency {
	'oxmysql'
}
