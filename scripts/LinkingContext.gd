extends Reference

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


func append_property_hook(nid, target:Node, property:String, value, is_nid:bool=false):
	if not id_property_map.has(nid):
		id_property_map[nid] = []
	
	id_property_map[nid].append({
		"target":target,
		"property":property,
		"value":value,
		"is_nid":is_nid
	})

func invoke_property_hooks(n:Node):
	var nid = n.get_node("NetworkIdentifier").network_id
	if id_property_map.has(nid):
		var ps = id_property_map[nid]
		for p in ps:
			if p.is_nid:
				p.value = get_node(p.value)
			if p.target == null:
				n.set(p.property, p.value)
		id_property_map.erase(nid)









