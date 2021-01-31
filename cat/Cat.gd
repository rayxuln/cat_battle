extends KinematicBody2D

signal dead

remote var player_manager:Node = null

var move_speed = 10

var max_health = 5
var health = max_health
var mouse_count = 0
var defeated_cats = []

var has_emit_dead_signal = false

var dead = false
var dying = false

onready var collect_area = $RotatePos/CollectArea2D
onready var rotate_pos = $RotatePos
onready var throw_pos = $RotatePos/ThrowPosition2D
onready var camera = $Camera2D
onready var anime_tree = $AnimationTree

var Ball = preload("res://ball/Ball.tscn")
var throwing = false
var throw_direction = Vector2.RIGHT

var hurting = false

var catching = false

var last_attacker

func _ready():
	update_health_bar()
	update_mouse_count_label()
	
	rset_config("global_position", MultiplayerAPI.RPC_MODE_REMOTE)

func _process(delta):
	if get_tree().is_network_server():
		if health <= 0:
			if not hurting and not has_emit_dead_signal:
				has_emit_dead_signal = true
				go_die()
				emit_signal("dead")

#----- Methods -----
func synchronize(pid):
	rset_id(pid, "global_position", global_position)
	
	GameSystem.set_remote_node_reference(pid, self, "player_manager", player_manager)
	rpc_id(pid, "rpc_set_health", health)
	rpc_id(pid, "rpc_set_mouse_count", mouse_count)
	
	#anime
	rpc_id(pid, "rpc_set_rotate_pos_scale_x", rotate_pos.scale.x)
	rpc_id(pid, "rpc_set_anime_cond", anime_tree["parameters/conditions/walk"], anime_tree["parameters/walk/blend_position"])

func set_player_name(n):
	$UI/NameLabel.text = n

func is_input_action_pressed(input, action):
	var last_var = "_last_" + action
	if not has_meta(last_var):
		set_meta(last_var, 0)
	var pressed = input[action]
	if not pressed is bool:
		pressed = true if input[action] != 0 else false
	var res = pressed and pressed != get_meta(last_var)
	set_meta(last_var, pressed)
	return res

func process_with_input(delta, input):
	if hurting or dying or catching or throwing:
		return
	
	var mouse_pos:Vector2 = input.mouse_pos
	var input_vec:Vector2 = input.input_vec
	
	# movement
	move_and_slide(input_vec * delta * 1000 * move_speed)
	
	#flip
	if abs(input_vec.x) > 0:
		anime_tree["parameters/walk/blend_position"] = input_vec.x
	
	
	if get_tree().is_network_server():
		#collect mouse
		if not catching:
			var collect = is_input_action_pressed(input, "collect")
			if collect:
				collect_mouse()
		
		#throw ball
		if not throwing:
			var throw = is_input_action_pressed(input, "throw")
			if throw:
				var d = (mouse_pos - throw_pos.global_position).normalized()
				
				rotate_pos.scale.x = sign(d.x)
				anime_tree["parameters/walk/blend_position"] = sign(d.x)
				
				# sync animation
				rpc("rpc_set_rotate_pos_scale_x", rotate_pos.scale.x)
				rpc("rpc_set_anime_cond", anime_tree["parameters/conditions/walk"], anime_tree["parameters/walk/blend_position"])
				
				spawn_curser(mouse_pos)
				
				throw_ball(d)
	
		#update anime
		anime_tree["parameters/conditions/walk"] = input_vec.length() > 0.1
		anime_tree["parameters/conditions/not_walk"] = not anime_tree["parameters/conditions/walk"]
		
		rset("global_position", global_position)
		rpc("rpc_set_anime_cond", anime_tree["parameters/conditions/walk"], anime_tree["parameters/walk/blend_position"])

func play_catch_anime():
	rpc("rpc_play_catch_anime")

func collect_mouse():
	play_catch_anime()

func play_throw_ball_anime():
	rpc("rpc_play_throw_ball_anime")

func throw_ball(d):
	play_throw_ball_anime()
	throw_direction = d

func update_mouse_count_label():
	if player_manager and player_manager.is_network_master():
		GameSystem.game_manager.player_mouse_count_label.text = str(mouse_count)

func update_health_bar():
	$UI/HealthBar.max_value = max_health
	$UI/HealthBar.target_value = health
	
	if player_manager and player_manager.is_network_master():
		GameSystem.game_manager.player_heart_group.value = health

func play_hurt_anime():
	rpc("rpc_play_hurt_anime")

func take_damage(d, attacker=null):
	if attacker:
		play_hurt_anime()
	
	last_attacker = attacker
	health -= d
	health = clamp(health, 0, max_health)
	update_health_bar()
	rpc("rpc_set_health", health)

func show_ui(v=true):
	$UI/NameLabel.visible = v
	$UI/HealthBar.visible = v

func go_die():
	if last_attacker:
		last_attacker.defeated_cats.append(player_manager.player_name)
		GameSystem.send_boardcast("> %s被%s干掉了！" % [player_manager.player_name, last_attacker.player_manager.player_name])
	
	rpc("rpc_go_die")

func go_live():
	rpc("rpc_go_live")

func disable_collision():
	$CollisionShape2D.disabled = true

func enable_collision():
	$CollisionShape2D.disabled = false

func spawn_curser(p):
	var pid = player_manager.get_network_master()
	rpc_id(pid, "rpc_spawn_curser", p)

#----- RPCs -----
remote func rpc_set_anime_cond(walk, walk_blend_position):
	anime_tree["parameters/conditions/walk"] = walk
	anime_tree["parameters/conditions/not_walk"] = not walk
	anime_tree["parameters/walk/blend_position"] = walk_blend_position

remote func rpc_set_health(h):
	health = h
	update_health_bar()

remotesync func rpc_set_mouse_count(m):
	mouse_count = m
	update_mouse_count_label()

remotesync func rpc_go_die():
	anime_tree["parameters/playback"].travel("dead")
	dying = true
	show_ui(false)
	disable_collision()

remotesync func rpc_go_live():
	anime_tree["parameters/playback"].travel("idle")
	
	dead = false
	dying = false
	catching = false
	throwing = false
	hurting = false
	show_ui(true)
	enable_collision()
	
	if get_tree().is_network_server():
		health = max_health
		mouse_count = 0
		has_emit_dead_signal = false
		defeated_cats.clear()
		
		update_health_bar()
		update_mouse_count_label()
		
		rpc("rpc_set_health", health)
		rpc("rpc_set_mouse_count", mouse_count)
		rset("global_position", global_position)
	
remotesync func rpc_play_hurt_anime():
	anime_tree["parameters/playback"].travel("hurt")
	hurting = true

remotesync func rpc_play_catch_anime():
	anime_tree["parameters/playback"].travel("catch")
	catching = true

remotesync func rpc_play_throw_ball_anime():
	anime_tree["parameters/playback"].travel("throw")
	throwing = true

remotesync func rpc_spawn_curser(p):
	var c = preload("res://curser/Curser.tscn").instance()
	c.global_position = p
	GameSystem.game_manager.world.add_child(c)

remote func rpc_set_rotate_pos_scale_x(sx):
	rotate_pos.scale.x = sx
#----- Animation Events -----
func _on_throw_ball():
	if not get_tree().is_network_server():
		return
	
#	GameSystem.send_boardcast("%s向%s抛了个毛球" % [player_manager.player_name, str(throw_direction)])
	var ball = GameSystem.instance_network_node(Ball)
	ball.global_position = throw_pos.global_position
	ball.move_direction = throw_direction
	ball.attacker = self
	GameSystem.game_manager.world.add_child(ball)

func _on_throw_done():
	throwing = false

func _on_hurt_done():
	hurting = false

func _on_dead_done():
	dead = true
	dying =false

func _on_catch():
	if get_tree().is_network_server():
		
		var m = null
		var ms = collect_area.get_overlapping_bodies()
		for mm in ms:
			if not mm.dying:
				m = mm
				break
		if not m:
			return
		
		m.go_die()
		mouse_count += 1
		
		take_damage(-1)
		
		rpc_id(player_manager.get_network_master(), "rpc_set_mouse_count", mouse_count)

func _on_catch_done():
	catching = false
		
		
		
		
		
		
		
		
		
		














