extends AcceptDialog


onready var address:LineEdit = $VBoxContainer/HBoxContainer/AddressLineEdit
onready var player_name:LineEdit = $VBoxContainer/HBoxContainer2/PlayerNameLineEdit

#----- Methods -----
func get_address():
	var a = address.text
	a = a.split(":")
	return a[0]

func get_port():
	var a = address.text
	a = a.split(":")
	if a.size() > 1:
		if not a[1].empty():
			return int(a[1])
	return GameSystem.default_port
