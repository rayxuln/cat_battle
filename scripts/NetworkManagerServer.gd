extends NetworkManager

class_name NetworkManagerServer

signal server_started
signal server_fail
signal client_connected
signal client_disconnected

var client_proxy_map:Dictionary = {}

func _ready():
	.init()
	init()

#----- Methods -----
func init():
	peer = NetworkedMultiplayerENet.new()
	var error = peer.create_server(port)
	if error != OK:
		GameSystem.send_msg("无法在%d端口上创建服务器！（可能端口被占用了）" % port)
		emit_signal("server_fail")
		return error
	
	get_tree().network_peer = peer
	emit_signal("server_started")
	
	return OK
	
func add_client_proxy(client_proxy):
	client_proxy_map[client_proxy.peer_id] = client_proxy
	add_child(client_proxy)
	
func remove_client_proxy(client_proxy):
	client_proxy_map.erase(client_proxy.peer_id)
	client_proxy.queue_free()
	
func network_peer_connected(id):
	if client_proxy_map.has(id):
		return
	var client_proxy:ClientProxy = ClientProxy.new()
	client_proxy.peer_id = id
	add_client_proxy(client_proxy)
	GameSystem.send_msg("客户端(%d)连接" % id)
	emit_signal("client_connected", client_proxy)
	
func network_peer_disconnected(id):
	if not client_proxy_map.has(id):
		return
	var client_proxy:ClientProxy = client_proxy_map[id]
	
	GameSystem.send_msg("客户端(%d)断开连接" % id)
	emit_signal("client_disconnected", client_proxy)
	
	remove_client_proxy(client_proxy)
	
	
	
	
