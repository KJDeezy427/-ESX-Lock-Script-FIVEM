fx_version 'cerulean'
game 'gta5'

description 'ESX Key Lock System'
author 'DEEZY'
version '2.0.0'

shared_script 'config.lua'

client_script 'client.lua'
server_script 'server.lua'

dependencies {
    'es_extended',
    'ox_lib'
}

lua54 'yes'