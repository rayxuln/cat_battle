extends ProgressBar


var target_value:float = 0

func _process(delta):
	value = lerp(value, target_value, 0.1)
