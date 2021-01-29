extends HBoxContainer


export(int) var value = 3 setget _on_set_value
func _on_set_value(v):
	if v != value:
		clear_heart()
		for _i in range(v):
			add_heart()
		value = v

func _ready():
	for _i in range(value):
		add_heart()

#----- Methods -----
func add_heart():
	var h = TextureRect.new()
	h.expand = true
	h.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	h.texture = preload("res://ui/heart.png")
	h.rect_min_size = Vector2(64, 64)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(h)

func clear_heart():
	for c in get_children():
		c.queue_free()














