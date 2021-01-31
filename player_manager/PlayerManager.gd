extends Node


var player_name =  "123123"

var Cat = preload("res://cat/Cat.tscn")
remote var cat:Node2D = null

var enable_input:bool = true

var ready_for_competition:bool = false

var touch_global_position:Vector2 = Vector2.ZERO

class MoveList:
	extends Reference
	
	var moves:Array
	
	var last_move_timestamp = -1
	
	func add_move(input, timestamp):
		var delta = timestamp - last_move_timestamp if last_move_timestamp >= 0 else 0
		last_move_timestamp = timestamp
		
		moves.append({
			"input": input,
			"delta": delta / 1000.0,
			"timestamp": timestamp
		})
		
	func has_move():
		return moves.size() > 0
	
	func last_move():
		return moves.back()
var move_list:MoveList = MoveList.new()
	
	


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
	GameSystem.set_remote_node_reference(pid, self, "cat", cat)
	
	rpc_id(pid, "rpc_set_player_name", player_name)
	rpc_id(pid, "rpc_set_network_master", get_network_master())

func update_ui():
	GameSystem.game_manager.player_name_label.text = player_name

func process_move_list():
	for move in move_list.moves:
		var input = move.input
		var d = move.delta
		cat.process_with_input(d, input)
	
	move_list.moves.clear()

func get_random_spawn_point():
	var ps = get_tree().get_nodes_in_group("cat_spawn_point")
	return ps[randi()%ps.size()].global_position

func spawn_cat():
	var pos = get_random_spawn_point()
	var c = GameSystem.instance_network_node(Cat)
	c.player_manager = self
	GameSystem.game_manager.world.add_child(c)
	c.global_position = pos
	cat = c
	

func fetch_input(delta):
	var input_vec = Vector2.ZERO
	var input = {}
	
	input_vec.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vec.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	get_input(input, "collect")
	get_input(input, "throw")
	input["mouse_pos"] = cat.get_global_mouse_position()
	input["input_vec"] = input_vec
	
	move_list.add_move(input, OS.get_system_time_msecs())
	
	if move_list.has_move():
		if not get_tree().is_network_server():
			rpc_id(1, "rpc_recieve_input", move_list.last_move())
			
			move_list.moves.clear()
	

func get_input(input, action):
	input[action] = Input.get_action_strength(action)

func respawn_cat():
	rpc_id(1, "rpc_respawn_cat")

func set_player_name(p_name):
	player_name = p_name
	cat.set_player_name(player_name)
	
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
	move_list.moves.append(move)

remotesync func rpc_respawn_cat():
	cat.global_position = get_random_spawn_point()
	cat.go_live()
	
	ready_for_competition = true













