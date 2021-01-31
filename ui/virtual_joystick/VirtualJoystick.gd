extends Control

export(String) var action_name_up = "vj_up"
export(String) var action_name_down = "vj_down"
export(String) var action_name_left = "vj_left"
export(String) var action_name_right = "vj_right"

export(float) var dead_zone = 0.1


var touch_id = -1
onready var thumb_center_position = ($Background.rect_size - $Background/Thumb.rect_size) / 2.0
onready var radius = $Background.rect_size.x / 2.0

func _input(event):
	if event is InputEventScreenTouch:
		if event.index == touch_id and not event.pressed:
			touch_id = -1
			set_thumb_position(Vector2.ZERO)
			reset_input_events()
	elif event is InputEventScreenDrag:
		if event.index == touch_id:
			event.position -= rect_global_position
		handle_touch(event)

#-------- methods -------------------
func set_thumb_position(pos):
	var thumb_vec
	if pos.length() <= radius:
		thumb_vec = pos
	else:
		thumb_vec = pos.normalized() * radius
	$Background/Thumb.rect_position = thumb_center_position + thumb_vec
	return thumb_vec

func reset_input_events():
	var action_event = InputEventAction.new()
	action_event.pressed = false
	action_event.strength = 0
	action_event.action = action_name_up
	Input.parse_input_event(action_event)
	action_event.action = action_name_down
	Input.parse_input_event(action_event)
	action_event.action = action_name_left
	Input.parse_input_event(action_event)
	action_event.action = action_name_right
	Input.parse_input_event(action_event)

func feed_action_event(action_name, strength):
	var action_event = InputEventAction.new()
	action_event.action = action_name
	action_event.strength = strength
	action_event.pressed = action_event.strength > dead_zone
	Input.parse_input_event(action_event)

func handle_touch(event):
	if event.index == touch_id:
		var thumb_vec_transformed = set_thumb_position(event.position) / radius
		feed_action_event(action_name_up, abs(thumb_vec_transformed.y) if thumb_vec_transformed.y < 0 else 0)
		feed_action_event(action_name_down, abs(thumb_vec_transformed.y) if thumb_vec_transformed.y > 0 else 0)
		feed_action_event(action_name_left, abs(thumb_vec_transformed.x) if thumb_vec_transformed.x < 0 else 0)
		feed_action_event(action_name_right, abs(thumb_vec_transformed.x) if thumb_vec_transformed.x > 0 else 0)
		

#--------- singals ------------------
func _on_VirtualJoystick_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if touch_id == -1:
				touch_id = event.index
				handle_touch(event)
