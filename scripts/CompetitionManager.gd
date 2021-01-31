extends Node

var competition_started = false
var competition_summaried = false

var enable = false

func _process(delta):
	if enable:
		if not competition_started:
			var ps = get_tree().get_nodes_in_group("player_manager")
			var not_ready_player = 0
			for p in ps:
				if not p.ready_for_competition:
					not_ready_player += 1
					break
			if not_ready_player == 0 and ps.size() >= 2:
				competition_begin()
		
		if competition_started and not competition_summaried:
			var cs = get_tree().get_nodes_in_group("cat")
			var live_cat = 0
			var last_live_cat = null
			for c in cs:
				if not c.dead:
					live_cat += 1
					last_live_cat = c
					if live_cat >= 2:
						break
			if live_cat == 1:
				summary(last_live_cat)

#----- Methods -----
func competition_begin():
	competition_started = true
	competition_summaried = false
	GameSystem.send_boardcast("> 回合开始！")

func summary(winner):
	competition_started = false
	competition_summaried = true
	var client_proxy_map:Dictionary = GameSystem.network_manager.client_proxy_map
	for cp in client_proxy_map.values():
		if cp:
			cp.show_summary(winner)
	
	GameSystem.send_boardcast("> %s 击败了所有猫咪取得了最终胜利！" % winner.player_manager.player_name)









