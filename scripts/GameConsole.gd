extends Node


var console_ui:Node = null

#----- Methods -----
func send_msg(s):
	if OS.has_feature("Server") or "--server" in OS.get_cmdline_args():
		print(s)
	console_ui.add_label(s)

func send_feedback(s, sender):
	if sender:
		var pid = sender.get_network_master()
		if pid == get_tree().get_network_unique_id():
			send_msg(s)
		else:
			rpc_id(pid, "rpc_send_msg", s)
	else:
		send_msg(s)

func send_chat(s, sender=null):
	if sender == null:
		sender = GameSystem.main_player_manger
	if sender:
		var nid = sender.get_node("NetworkIdentifier").network_id
		rpc_id(1, "rpc_send_chat", nid, s)
	else:
		send_msg(s)

func send_boardcast(s):
	if not GameSystem.is_game_started():
		send_msg(s)
		return
	rpc_id(1, "rpc_send_boardcast", s)
	
func send_cmd(s, sender=null):
	if not sender:
		console_ui.add_history(s)
		if GameSystem.main_player_manger and not get_tree().is_network_server():
			var nid = GameSystem.main_player_manger.get_node("NetworkIdentifier").network_id
			rpc_id(1, "rpc_send_cmd", nid, s)
			return
		
		if GameSystem.main_player_manger and get_tree().is_network_server():
			sender = GameSystem.main_player_manger
	
	var parsed_cmd = parse_cmd(s)
	if not parsed_cmd:
		var temp = sender if sender else GameSystem.main_player_manger
		send_chat(s, temp)
		return
	
	if parsed_cmd.size() < 1:
		send_feedback("无法识别的指令：" + s, sender)
		return
	
	var cmd = "cmd_" + parsed_cmd[0]
	if has_method(cmd):
		call(cmd, sender, parsed_cmd[1])
	else:
		send_feedback("未定义的指令：" + parsed_cmd[0], sender)
	
	
func parse_cmd(s):
	if s == "":
		return null
	if s[0] != "/":
		return null
	s = s.substr(1)
	var ss = s.split(" ")
	
	var args = []
	var i=1
	while i<ss.size():
		args.append(ss[i])
		i += 1
	
	return [ss[0], args]
#----- CMDs -----
func cmd_say(sender, args):
	send_chat(args[0], sender)

#----- RPCs (server to client) -----
remote func rpc_send_msg(msg):
	send_msg(msg)

remote func rpc_send_cmd(sender_nid, cmd):
	var sender = GameSystem.linking_context.get_node(sender_nid)
	if sender:
		send_cmd(cmd, sender)
#----- Commands (client to server) -----
remotesync func rpc_send_chat(sender_nid, msg):
	var sender = GameSystem.linking_context.get_node(sender_nid)
	if sender:
		var m = "[%s(%d)]%s" % [sender.player_name, sender.get_network_master(), msg]
		send_msg(m)
		rpc("rpc_send_msg", m)

remotesync func rpc_send_boardcast(msg):
	send_msg(msg)
	rpc("rpc_send_msg", msg)









