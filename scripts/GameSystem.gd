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
func start_as_server(p_name, port:int):
	if network_manager != null:
		stop_network()
		
	player_name = p_name
	
	network_manager = NetworkManagerServer.new()
	network_manager.port = port
	network_manager.name = "NetworkManagerServer"
	
	network_manager.connect("server_started", self, "_on_server_started")
	network_manager.connect("server_fail", self, "_on_server_fail")
	
	add_child(network_manager)

func start_as_client(p_name, address:String, port:int):
	if network_manager != null:
		stop_network()
	
	player_name = p_name
	
	send_msg("正在连接服务器(%s:%d)..." % [address, port])
	network_manager = NetworkManagerClient.new()
	network_manager.server_address = address
	network_manager.port = port
	network_manager.name = "NetworkManagerClient"
	
	network_manager.connect("connected_to_server", self, "_on_connected_to_server")
	network_manager.connect("connection_failed", self, "_on_connection_failed")
	network_manager.connect("server_disconnected", self, "_on_server_disconnected")
	
	add_child(network_manager)

func load_world():
	pass

func start_game():
	load_world()
	
	game_started = true
	emit_signal("game_start")

func stop_game():
	game_started = false
	emit_signal("game_stop")
	
	if game_manager.world:
		game_manager.world.queue_free()
		game_manager.world = null
		
func is_game_started():
	return game_started

func stop_network():
	network_manager.queue_free()
	network_manager = null
	

func set_main_player_manager(p):
	main_player_manger = p

func add_server_side_player():
	pass

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
#----- RPCs -----
#----- Signals -----
func _on_connected_to_server():
	game_manager.hide_ui()
	game_manager.show_hud()
	start_game()
	send_msg("连接到服务器成功！")

func _on_connection_failed():
	game_manager.show_ui()
	send_msg("连接到服务器失败！")
	
	stop_network()

func _on_server_disconnected():
	game_manager.show_ui()
	game_manager.hide_hud()
	game_manager.hide_panels()
	
	stop_game()
	send_msg("与服务器断开连接！")

	stop_network()

func _on_server_fail():
	stop_game()
	send_msg("创建服务器失败！")
	game_manager.show_ui()
	
	stop_network()

func _on_server_started():
	send_msg("创建服务器(端口：%d)成功！" % network_manager.port)
	game_manager.hide_ui()
	game_manager.show_hud()
	
	start_game()
	
	add_server_side_player()
	
	send_boardcast("> 等待其他玩家加入...")



