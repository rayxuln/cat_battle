extends TextureRect


export(String) var action_name = "vj_fire"

var touch_id = -1

func _input(event):
	if event is InputEventScreenTouch:
		if event.index == touch_id and not event.pressed:
			touch_id = -1
			reset_input_events()

#-------- methods -------------------
func reset_input_events():
	var action_event = InputEventAction.new()
	action_event.pressed = false
	action_event.strength = 0
	action_event.action = action_name
	Input.parse_input_event(action_event)

func feed_action_event(action):
	var action_event = InputEventAction.new()
	action_event.action = action
	action_event.strength = 1
	action_event.pressed = true
	Input.parse_input_event(action_event)

func handle_touch(event):
	if event.index == touch_id:
		feed_action_event(action_name)
		

#--------- singals ------------------
func _on_VirtualButton_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if touch_id == -1:
				touch_id = event.index
				handle_touch(event)
