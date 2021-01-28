extends NetworkManager

class_name NetworkManagerClient

signal connected_to_server
signal connection_failed
signal server_disconnected

var server_address = "localhost"

func _ready():
	.init()
	init()

#----- Methods -----
func init():
	peer = NetworkedMultiplayerENet.new()
	var error = peer.create_client(server_address, port)
	if error != OK:
		GameSystem.send_msg("无法连接到服务器：%s:%d" % [server_address, port])
		return error
	
	get_tree().network_peer = peer
	return OK
	
func connected_to_server():
	emit_signal("connected_to_server")
	GameSystem.send_msg("连接到服务器 %s:%d成功！" % [server_address, port])

func connection_failed():
	emit_signal("connection_failed")
	GameSystem.send_msg("连接到服务器 %s:%d失败！" % [server_address, port])
	
func server_disconnected():
	emit_signal("server_disconnected")
	
	
	
	
	
