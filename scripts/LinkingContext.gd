extends Node

class_name LinkingContext

signal network_node_added(nid, node)

var id_node_map = {}

var network_id_count = 0

var id_property_map = {}

func get_new_network_id():
	var res = network_id_count
	network_id_count += 1
	return res

func add_node(n:Node, id=-1):
	if id == -1:
		id = get_new_network_id()
		n.get_node("NetworkIdentifier").network_id = id
	id_node_map[id] = n
	yield(n, "ready")
	emit_signal("network_node_added", id, n)

func remove_node(id):
	id_node_map.erase(id)

func get_node(id):
	if id_node_map.has(id):
		return id_node_map[id]
	return null














