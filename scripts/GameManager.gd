extends Node


onready var world:Node = null
onready var player_name_label:Label
onready var player_heart_group
onready var play_mouse_count_label:Label
onready var summary_panel:Panel
onready var chat_display = $UILayer/Control/ChatDipaly
onready var pause_panel:Panel
onready var main_menu:Control = $UILayer/Control/MainMenu
onready var create_host_dialog:AcceptDialog
onready var connect_to_host_dialog:AcceptDialog
onready var screen_touch_ui:Control
onready var sound_player:AudioStreamPlayer

func _ready():
	GameSystem.set_game_manager(self)
	show_ui()
	hide_hud()
	hide_panels()

#----- Methods -----
func hide_ui():
	main_menu.visible = false

func show_ui():
	main_menu.visible = true

func hide_hud():
	pass
	
func show_hud():
	pass

func hide_panels():
	pass
	

#----- Signals -----
func _on_ChatDipaly_command_entered(cmd):
	GameSystem.send_cmd(cmd)
