extends Node


onready var network_id setget _on_set_network_id
func _on_set_network_id(v):
	network_id = v
	get_parent().name = "[%s]NetworkObject_%d" % [get_parent().name, v]
	

func _ready():
	get_parent().add_to_group("network")
	if get_tree().is_network_server():
		GameSystem.linking_context.add_node(get_parent())
	
func _exit_tree():
	GameSystem.linking_context.remove_node(network_id)
