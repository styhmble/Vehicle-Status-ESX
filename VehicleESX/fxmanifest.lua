fx_version "cerulean"
game "gta5"

author "Shook"
description "STL Vehicle Status ESX"
version "1.0.0"

ui_page "html/ui.html"

files {
    "html/ui.html",
    "html/script.js",
}

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua",
    "shared/utils.lua",
}

client_scripts {
    "client/main.lua",
}

server_scripts {
    "sv_config.lua",
    "server/main.lua",
}

dependencies {
    "es_extended",
    "ox_lib",
}