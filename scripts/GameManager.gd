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
onready var sound_player:AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	GameSystem.set_game_manager(self)
	show_ui()
	hide_hud()
	hide_panels()
	
	if OS.has_feature("Server") or "--server" in OS.get_cmdline_args():
		var args = OS.get_cmdline_args()
		var port = GameSystem.default_port
		for arg in args:
			if arg.find("port") > -1:
				var ps = arg.split("=")
				if ps.size() > 1:
					port = int(ps[1])
		GameSystem.send_boardcast("正在启动服务器：%d" % port)
		yield(get_tree().create_timer(1), "timeout")
		GameSystem.start_as_server("Server", port)

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

func play_button_sound():
	sound_player.stream = preload("res://sounds/button.wav")
	sound_player.play()

func play_pause_sound(v:bool):
	if v:
		sound_player.stream = preload("res://sounds/pause_in.wav")
	else:
		sound_player.stream = preload("res://sounds/pause_out.wav")
	
	sound_player.play()
#----- Signals -----
func _on_ChatDipaly_command_entered(cmd):
	GameSystem.send_cmd(cmd)


func _on_ServerButton_pressed():
	show_create_host_dialog()
	play_button_sound()

func _on_ClientButton_pressed():
	show_connect_to_host_dialog()
	play_button_sound()

func _on_QuitButton_pressed():
	play_button_sound()
	
	get_tree().quit(0)


func _on_CreateHostDialog_confirmed():
	play_button_sound()
	GameSystem.start_as_server(create_host_dialog.player_name.text, create_host_dialog.get_port())
	

func _on_ConnectToHostDialog_confirmed():
	play_button_sound()
	GameSystem.start_as_client(connect_to_host_dialog.player_name.text, connect_to_host_dialog.get_address(), connect_to_host_dialog.get_port())
	
	

func _on_PausePanel_go_to_main_menu():
	play_button_sound()
	
	GameSystem.stop_game()
	GameSystem.stop_network()
	
	show_ui()
	hide_hud()


func _on_SummaryPanel_go_to_main_menu():
	play_button_sound()
	
	GameSystem.stop_game()
	GameSystem.stop_network()
	
	show_ui()
	hide_hud()


func _on_SummaryPanel_restart():
	play_button_sound()
	
	GameSystem.main_player_manger.respawn_cat()
	GameSystem.main_player_manger.enable_input = true


func _on_ChatDipaly_history_hide():
	if GameSystem.main_player_manger:
		GameSystem.main_player_manger.enable_input = true


func _on_ChatDipaly_history_show():
	if GameSystem.main_player_manger:
		GameSystem.main_player_manger.enable_input = false


func _on_PausePanel_visibility_changed():
	play_pause_sound(pause_panel.visible)
