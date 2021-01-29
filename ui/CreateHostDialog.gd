extends AcceptDialog


onready var port:LineEdit = $VBoxContainer/HBoxContainer/PortLineEdit
onready var player_name:LineEdit = $VBoxContainer/HBoxContainer2/PlayerNameLineEdit

#----- Methods -----
func get_port():
	if port.text.empty():
		return GameSystem.default_port
	return int(port.text)
