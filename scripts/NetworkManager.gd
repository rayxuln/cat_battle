extends Node


class_name NetworkManager

export(int) var port = 25578

var peer:NetworkedMultiplayerENet = null

func _exit_tree():
	if peer and get_tree().network_peer == peer:
		get_tree().network_peer = null
		peer = null

#----- Methods -----
func init():
	get_tree().connect("network_peer_connected", self, "network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "network_peer_disconnected")
	
	get_tree().connect("connected_to_server", self, "connected_to_server")
	get_tree().connect("connection_failed", self, "connection_failed")
	get_tree().connect("server_disconnected", self, "server_disconnected")

func network_peer_connected(var id):
	pass

func network_peer_disconnected(var id):
	pass
	
func connected_to_server():
	pass

func connection_failed():
	pass

func server_disconnected():
	pass


