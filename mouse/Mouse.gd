extends KinematicBody2D


var think_time_stamp = 0
var think_time = 5000

var move_direction = Vector2.UP
var move_speed = 100
var move_time_stamp = 0
var move_time = 5000

var thinking = false
var moving = false
var dying = false

onready var anime_tree = $AnimationTree
onready var sound_player = $AudioStreamPlayer2D

func _ready():
	if get_tree().is_network_server():
		yield(self, "ready")
		start_think()
	
	rset_config("global_position", MultiplayerAPI.RPC_MODE_REMOTE)

func _process(delta):
	if not get_tree().is_network_server():
		return
	
	if thinking and is_think_time_out():
		thinking = false
		if not dying:
			var r = randi() % 10
			if r <= 7:
				start_move() # 80%
			else:
				go_in() # 20%
	
	if moving and is_move_time_out():
		moving = false
		if not dying:
			start_think()

func _physics_process(delta):
	if moving:
		move()

func play_dead_sound():
	sound_player.stream = preload("res://sounds/mouse_dead.wav")
	sound_player.play()

func play_hurt_sound():
	sound_player.stream = preload("res://sounds/hit1.wav")
	sound_player.play()
#----- Methods -----
func synchronize(pid):
	rset_id(pid, "global_position", global_position)
	if moving:
		rpc_id(pid, "rpc_play_walk_anime")

func get_new_think_time():
	return rand_range(3000, 8000)

func get_new_move_time():
	return rand_range(4000, 8000)

func start_think():
	thinking = true
	think_time = get_new_think_time()
	think_time_stamp = OS.get_ticks_msec()
	
	rpc("rpc_play_idle_anime")

func get_random_move_direction():
	return move_direction.rotated(deg2rad(randi()%360))

func start_move():
	moving = true
	move_time = get_new_move_time()
	move_direction = get_random_move_direction()
	move_time_stamp = OS.get_ticks_msec()
	
	rpc("rpc_play_walk_anime")

func is_think_time_out():
	return OS.get_ticks_msec() - think_time_stamp >= think_time

func is_move_time_out():
	return OS.get_ticks_msec() - move_time_stamp >= move_time
	
func move():
	move_and_slide(move_direction * move_speed)
	
	rset("global_position", global_position)
	rpc("rpc_set_walk_blend_pos", sign(move_direction.x))

func go_die():
	dying = true
	rpc("rpc_play_die_anime")

func go_in():
	dying = true
	rpc("rpc_play_in_anime")
	

#----- RPCs -----
remotesync func rpc_play_walk_anime():
	anime_tree["parameters/playback"].travel("walk")

remotesync func rpc_play_idle_anime():
	anime_tree["parameters/playback"].travel("idle")

remotesync func rpc_set_walk_blend_pos(x):
	anime_tree["parameters/walk/blend_position"].x = x

remotesync func rpc_play_die_anime():
	anime_tree["parameters/playback"].travel("die")

remotesync func rpc_play_in_anime():
	anime_tree["parameters/playback"].travel("in")

#----- Animation Events -----
func _on_die_done():
	if get_tree().is_network_server():
		queue_free()
	
	
	
	
	



