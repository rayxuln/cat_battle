extends RigidBody2D


var attacker

var move_speed = 275
var move_direction = Vector2.RIGHT
var life_time = 2 #sec

var is_crashing = false

func _ready():
	if get_tree().is_network_server():
		self_destruction()
	
	linear_velocity = move_direction * move_speed

#----- Methods -----
func synchronize(pid):
	rpc_id(pid, "rpc_init_ball", global_position, move_direction)
	
func self_destruction():
	get_tree().create_timer(life_time).connect("timeout", self, "play_crash_anime")

func play_crash_anime():
	if not is_crashing:
		is_crashing = true
		rpc("rpc_play_crash_anime")
#----- RPCs -----
remote func rpc_init_ball(gp, md):
	global_position = gp
	move_direction = md
	
	linear_velocity = move_direction * move_speed

remotesync func rpc_play_crash_anime():
	$AnimationPlayer.play("crash")
#----- Animation Events -----
func _on_crash_anime_done():
	if get_tree().is_network_server():
		queue_free()
	
#----- Signals ------
func _on_HitArea2D_body_entered(body):
	if is_crashing:
		return
	if not get_tree().is_network_server():
		return
	if body == attacker:
		return
	if not body.is_in_group("cat"):
		return
	
	body.take_damage(1, attacker)
	
	play_crash_anime()
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
