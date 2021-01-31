extends Node


signal game_start
signal game_stop

var game_manager:Node = null
var network_manager = null
var game_console:Node = null
var linking_context:LinkingContext = null

var main_player_manger:Node = null
var player_name = "asdasd"
var default_port = 25578

var game_started = false

var competition_manager:Node = null

func _ready():
	competition_manager = preload("res://scripts/CompetitionManager.gd").new()
	competition_manager.name = "CompetitionManager"
	add_child(competition_manager)
	
	game_console = preload("res://scripts/GameConsole.gd").new()
	game_console.name = "GameConsole"
	add_child(game_console)
	
	linking_context = LinkingContext.new()
	linking_context.connect("network_node_added", self, "_on_network_node_added")
	
	randomize()

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		Input.action_press("ui_cancel")
		yield(get_tree().create_timer(0.5), "timeout")
		Input.action_release("ui_cancel")
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
	var w = load("res://world/test/World.tscn").instance()
	game_manager.add_child(w)
	game_manager.world = w
	game_manager.move_child(w, 0)

func set_remote_node_reference(pid, target:Node, property, value:Node):
	var t_nid = target.get_node("NetworkIdentifier").network_id
	var v_nid = value.get_node("NetworkIdentifier").network_id
	rpc_id(pid, "rpc_set_node_reference", t_nid, property, v_nid)

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
	
func instance_network_node(res:PackedScene):
	var n = res.instance()
	n.set_meta("_resource_path", res.resource_path)
	return n

func stop_network():
	network_manager.queue_free()
	network_manager = null
	
	competition_manager.enable = false
	

func set_main_player_manager(p):
	main_player_manger = p
	main_player_manger.cat.camera.make_current()
	

func add_server_side_player():
	network_manager.network_peer_connected(1)
	var c = network_manager.client_proxy_map[1]
	c.player_manager.set_player_name(player_name)
	set_main_player_manager(c.player_manager)
	main_player_manger.ready_for_competition = true

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
remote func rpc_add_node(resource_path, nid):
	if linking_context.get_node(nid):
		return
	var n = load(resource_path).instance()
	n.get_node("NetworkIdentifier").network_id = nid
	
	linking_context.add_node(n, nid)
	game_manager.world.add_child(n)

remote func rpc_remove_node(nid):
	var n = linking_context.get_node(nid)
	if n:
		n.queue_free()

remote func rpc_set_node_reference(t_nid, property, v_nid):
	var target = linking_context.get_node(t_nid)
	var value = linking_context.get_node(v_nid)
	if value == null:
		linking_context.append_property_hook(v_nid, target, property, v_nid, true)
	else:
		target.set(property, value)

remotesync func rpc_show_summary(stats):
	main_player_manger.enable_input = false
	game_manager.show_summary_panel(stats)
	
#----- Signals -----
func _on_network_node_added(nid, node:Node):
	linking_context.invoke_property_hooks(node)

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
	
	if not OS.has_feature("Server") and not "--server" in OS.get_cmdline_args():
		add_server_side_player()
	
	competition_manager.enable = true
	send_boardcast("> 等待其他玩家加入...")



