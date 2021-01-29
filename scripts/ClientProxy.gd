extends Node


class_name ClientProxy

var player_manager:Node = null
var peer_id = -1


func _ready():
	GameSystem.linking_context.connect("network_node_added", self, "_on_network_node_added")
	get_tree().connect("node_removed", self, "_on_node_removed")
	
	add_player_manager()
	
	add_exist_nodes([player_manager])

func _exit_tree():
	if player_manager:
		player_manager.queue_free()

#----- Methods -----
func is_server():
	return peer_id == 1

func add_player_manager():
	pass

func add_exist_nodes(exclude=[]):
	if is_server():
		return
	
	var ns = get_tree().get_nodes_in_group("network")
	for node in ns:
		if not node in exclude:
			GameSystem.rpc_id(peer_id, "rpc_add_node", node.get_meta("_resource_path"), node.get_node("NetworkIdentifier").network_id)
	for node in ns:
		if not node in exclude:
			node.synchronize(peer_id)


#----- Signals -----
func _on_network_node_added(nid, node:Node):
	if is_server():
		return
	GameSystem.rpc_id(peer_id, "rpc_add_node", node.get_meta("_resource_path"), nid)
	node.synchronize(peer_id)

func _on_node_removed(node:Node):
	if is_server():
		return
	if not node.is_in_group("network"):
		return
	var nid = node.get_node("NetworkIdentifier").network_id
	GameSystem.rpc_id(peer_id, "rpc_remove_node", nid)







