extends Node


signal game_start
signal game_stop

var game_manager:Node = null
var network_manager = null
var game_console:Node = null
var linking_context = null

var main_player_manger:Node = null
var player_name = "asdasd"
var default_port = 25578

var game_started = false

var competition_manager:Node = null

func _ready():
	game_console = preload("res://scripts/GameConsole.gd").new()
	game_console.name = "GameConsole"
	add_child(game_console)

#----- Methods -----
func set_game_manager(gm):
	game_manager = gm
	game_console.console_ui = game_manager.chat_display

func send_msg(s):
	game_console.send_msg(s)

func send_feedback(s, sender):
	game_console.send_feedback(s, sender)

func send_chat(s, sender=null):
	game_console.send_chat(s, sender)

func send_boardcast(s):
	game_console.send_boardcast(s)
	
func send_cmd(s, sender=null):
	game_console.send_cmd(s, sender)
