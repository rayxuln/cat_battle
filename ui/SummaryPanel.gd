extends Panel

signal go_to_main_menu
signal restart


#----- Methods -----
func set_stats(stats):
	var is_win = stats.winner_pid == get_tree().get_network_unique_id()
	$TitileLabel.text = "你赢了！" if is_win else "你输了！"
	var msg = "%s 干掉了所有猫咪\n" % stats.winner
	var defeated_msg = "你干掉了：\n"
	var defeated_num = 0
	for c in stats.defeated_cats:
		defeated_msg += c + "\n"
		defeated_num += 1
	if defeated_num > 0:
		msg += defeated_msg
	msg += "总共吃掉了 %d 只美味多汁的老鼠" % stats.mouse_count
	$MsgLabel.text = msg

#----- Singals -----
func _on_MainMenuButton_pressed():
	visible = false
	emit_signal("go_to_main_menu")


func _on_RestartButton_pressed():
	visible = false
	emit_signal("restart")
