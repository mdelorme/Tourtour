extends TextureRect

const CREDITS_DURATION := 60.0
const CREDITS_PAUSE := 2.0

var game_finished := false

func _ready() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property($MarginContainer, 'modulate', Color(1.0, 1.0, 1.0, 1.0), 1.0)
	tween.tween_interval(CREDITS_PAUSE)
	tween.tween_property($MarginContainer, 'position', Vector2(0.0, -1100.0), CREDITS_DURATION)
	if game_finished:
		tween.tween_property($ThankYou, 'modulate', Color(1.0, 1.0, 1.0, 1.0), 1.0)
		tween.tween_interval(4.0)
		tween.tween_property($ThankYou, 'modulate', Color(1.0, 1.0, 1.0, 0.0), 2.0)
	tween.tween_callback(back_to_menu)
	
func _input(event: InputEvent) -> void:
	if event.is_action('ui_cancel'):
		var next_scene : Node = load('res://scenes/main_menu.tscn').instantiate()
		get_tree().root.add_child(next_scene)
		queue_free()
		
func back_to_menu() -> void:
	var menu : Node = load('res://scenes/main_menu.tscn').instantiate()
	get_tree().root.add_child(menu)
	queue_free()
