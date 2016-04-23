#\ -s puma

$LOAD_PATH << "lib"

require "play_by_play/web_app"

run PlayByPlay::WebApp
