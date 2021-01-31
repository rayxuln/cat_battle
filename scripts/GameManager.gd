extends Node


onready var world:Node = null
onready var player_name_label:Label = $UILayer/Control/HUD/Group1/PlayerNameLabel
onready var player_heart_group = $UILayer/Control/HUD/Group1/HeartGroup
onready var player_mouse_count_label:Label = $UILayer/Control/HUD/Group2/MouseCountLabel
onready var summary_panel:Panel = $UILayer/Control/SummaryPanel
onready var chat_display = $UILayer/Control/ChatDipaly
onready var pause_panel:Panel = $UILayer/Control/PausePanel
onready var main_menu:Control = $UILayer/Control/MainMenu
onready var create_host_dialog:AcceptDialog = $UILayer/Control/CreateHostDialog
onready var connect_to_host_dialog:AcceptDialog = $UILayer/Control/ConnectToHostDialog
onready var screen_touch_ui:Control
onready var sound_player:AudioStreamPlayer

func _ready():
	GameSystem.set_game_manager(self)
	show_ui()
	hide_hud()
	hide_panels()

func _process(delta):
	if GameSystem.is_game_started() and Input.is_action_just_pressed("ui_cancel"):
		pause_panel.visible = not pause_panel.visible
#----- Methods -----
func hide_ui():
	main_menu.visible = false

func show_ui():
	main_menu.visible = true

func hide_hud():
	$UILayer/Control/HUD.visible = false
	
	
func show_hud():
	$UILayer/Control/HUD.visible = true
	
func show_create_host_dialog():
	create_host_dialog.port.text = str(GameSystem.default_port)
	create_host_dialog.player_name.text = "123"
	create_host_dialog.popup_centered()

func show_connect_to_host_dialog():
	connect_to_host_dialog.player_name.text = "321"
	connect_to_host_dialog.popup_centered()

func hide_panels():
	summary_panel.visible = false
	pause_panel.visible = false
	
func show_summary_panel(stats):
	summary_panel.set_stats(stats)
	summary_panel.visible = true
#----- Signals -----
func _on_ChatDipaly_command_entered(cmd):
	GameSystem.send_cmd(cmd)


func _on_ServerButton_pressed():
	show_create_host_dialog()

func _on_ClientButton_pressed():
	show_connect_to_host_dialog()

func _on_QuitButton_pressed():
	get_tree().quit(0)


func _on_CreateHostDialog_confirmed():
	GameSystem.start_as_server(create_host_dialog.player_name.text, create_host_dialog.get_port())
	

func _on_ConnectToHostDialog_confirmed():
	GameSystem.start_as_client(connect_to_host_dialog.player_name.text, connect_to_host_dialog.get_address(), connect_to_host_dialog.get_port())
	
	

func _on_PausePanel_go_to_main_menu():
	GameSystem.stop_game()
	GameSystem.stop_network()
	
	show_ui()
	hide_hud()


func _on_SummaryPanel_go_to_main_menu():
	GameSystem.stop_game()
	GameSystem.stop_network()
	
	show_ui()
	hide_hud()


func _on_SummaryPanel_restart():
	GameSystem.main_player_manger.respawn_cat()
	GameSystem.main_player_manger.enable_input = true

	
	
	
	
	
	
	
	
	
	
	
