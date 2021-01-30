extends Position2D


var Mouse = preload("res://mouse/Mouse.tscn")

var min_time = 10 #sec
var max_time = 20 #sec

var timer:Timer = null

var max_mouse = 15

func _ready():
	GameSystem.connect("game_start", self, "_on_game_start")
	
	if get_tree().is_network_server():
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)
		timer.connect("timeout", self, "_on_timer_time_out")
	
	
#----- Methods -----
func spawn_mouse():
	var ms = get_tree().get_nodes_in_group("mouse")
	if ms.size() >= max_mouse:
		return
	var n = GameSystem.instance_network_node(Mouse)
	n.global_position = global_position
	GameSystem.game_manager.world.add_child(n)

func start_timer():
	timer.start(rand_range(min_time, max_time))

#----- Signals -----
func _on_game_start():
	if get_tree().is_network_server():
		spawn_mouse()
		start_timer()

func _on_timer_time_out():
	spawn_mouse()
	start_timer()
	
	
	
	
	
	
	
	
	
	
	
