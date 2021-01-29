extends Panel


signal go_to_main_menu

#----- Signals -----
func _on_MainMenuButton_pressed():
	visible = false
	emit_signal("go_to_main_menu")


func _on_RestartButton_pressed():
	visible = false
