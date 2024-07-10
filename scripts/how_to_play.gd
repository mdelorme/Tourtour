extends TextureRect


# Called when the node enters the scene tree for the first time.
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed('pause'):
		visible = false
