extends Control


signal history_show
signal history_hide
signal command_entered(cmd)

var live_time = 10000 #ms
var label_list = []
var max_history_panel_size_y = 315
var history_list = []
var history_max_size = 50
var current_history_cursor = -1

onready var default_container = $DefaultVBoxContainer
onready var history_container = $CmdVBoxContainer/HistoryScrollContainer/HistroyVBoxContainer
onready var history_panel = $CmdVBoxContainer/HistoryScrollContainer
onready var cmd_container = $CmdVBoxContainer
onready var cmd_line_edit = $CmdVBoxContainer/CmdLineEdit

export(bool) var enable:bool = true

func _ready():
	cmd_container.visible = false
	history_panel.rect_size.y = 0

func _process(delta):
	update_label_list()
	
	if enable and Input.is_action_just_pressed("display_chat"):
		show_history(not is_history_visible())
		
		if is_history_visible():
			emit_signal("history_show")
		else:
			emit_signal("history_hide")

#----- Metods -----
func update_label_list():
	var new_list = []
	var has_removed = false
	for l in label_list:
		if OS.get_ticks_msec() - l.stamp >= live_time:
			has_removed = true
			break
	
	if has_removed:
		for l in label_list:
			if OS.get_ticks_msec() - l.stamp < live_time:
				new_list.append(l)
			else:
				l.label.queue_free()
		
		label_list = new_list

func add_history(s):
	if history_list.size() > 0:
		if history_list.back() == s:
			return
	
	history_list.append(s)
	
	if history_list.size() > history_max_size:
		history_list.pop_front()

func add_label(s):
	var l = Label.new()
	l.text = s
	label_list.append({"label":l, "stamp":OS.get_ticks_msec()})
	default_container.add_child(l)

	l = Label.new()
	l.text = s
	history_container.add_child(l)
	
	if history_container.get_child_count() > 100:
		history_container.get_child(0).queue_free()
	
	if history_container.rect_size.y > max_history_panel_size_y and not history_panel.scroll_vertical_enabled:
		history_panel.scroll_vertical_enabled = true

func is_history_visible():
	return history_panel.is_visible_in_tree()

func show_history(display):
	default_container.visible = not display
	cmd_container.visible = display

	if display:
		cmd_line_edit.grab_focus()
		
		current_history_cursor = -1
		
		if history_panel.scroll_vertical_enabled:
			yield(get_tree(), "idle_frame")
			history_panel.rect_size.y = max_history_panel_size_y
			history_panel.rect_position.y = -max_history_panel_size_y
			history_panel.scroll_vertical = history_container.rect_size.y - history_panel.rect_size.y

#----- Signals -----	
func _on_CmdLineEdit_text_entered(new_text):
	if new_text != "":
		emit_signal("command_entered", new_text)
		cmd_line_edit.text = ""

func _on_CmdLineEdit_gui_input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.scancode == KEY_UP:
				if current_history_cursor == -1:
					current_history_cursor = history_list.size() - 1
				else:
					current_history_cursor -= 1
				
				if current_history_cursor < 0:
					current_history_cursor = 0
				
				if history_list.size() > 0:
					cmd_line_edit.text = history_list[current_history_cursor]
					cmd_line_edit.caret_position = cmd_line_edit.text.length()
			elif event.scancode == KEY_DOWN:
				if current_history_cursor != -1:
					current_history_cursor += 1
					
					if current_history_cursor >= history_list.size():
						current_history_cursor = -1
						cmd_line_edit.text = ""
					else:
						cmd_line_edit.text = history_list[current_history_cursor]
						cmd_line_edit.caret_position = cmd_line_edit.text.length()
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
