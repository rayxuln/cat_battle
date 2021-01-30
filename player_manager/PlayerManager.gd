extends Node


var player_name =  "123123"

var Cat
var cat:Node = null

var enable_input:bool = true

var ready_for_competition:bool = false

var touch_global_position:Vector2 = Vector2.ZERO


func _ready():
	if get_tree().is_network_server():
		spawn_cat()

func _exit_tree():
	if get_tree().is_network_server():
		GameSystem.send_boardcast("玩家%s退出了游戏" % player_name)
		if cat:
			cat.queue_free()

func _physics_process(delta):
	if cat and not cat.dead and enable_input and is_network_master():
		fetch_input(delta)
	
	if get_tree().is_network_server():
		process_move_list()
	
#----- Methods -----
func synchronize(pid):
	# rpc set cat
	
	rpc_id(pid, "rpc_set_player_name", player_name)
	rpc_id(pid, "rpc_set_network_master", get_network_master())

func update_ui():
	GameSystem.game_manager.player_name_label.text = player_name

func process_move_list():
	pass

func get_random_spawn_point():
	var ps = get_tree().get_nodes_in_group("cat_spawn_point")
	return ps[randi()%ps.size()].global_position

func spawn_cat():
	pass

func fetch_input(delta):
	pass

func respawn_cat():
	rpc_id(1, "rpc_respawn_cat")

func set_player_name(p_name):
	player_name = p_name
	
	if is_network_master():
		update_ui()

#----- RPCs (server to client)-----
remote func rpc_set_player_name(p_name):
	set_player_name(p_name)

remote func rpc_set_network_master(pid):
	set_network_master(pid)
	
	if is_network_master():
		rpc_id(1, "rpc_acknowledge_join_game", GameSystem.player_name)
		GameSystem.set_main_player_manager(self)
#----- Commands (client to server)-----
remotesync func rpc_acknowledge_join_game(p_name):
	set_player_name(p_name)
	ready_for_competition = true
	GameSystem.send_boardcast("玩家%s正式加入了游戏" % player_name)
	
	rpc("rpc_set_player_name", p_name)

remote func rpc_recieve_input(move):
	pass

remotesync func rpc_respawn_cat():
	
	
	ready_for_competition = true













