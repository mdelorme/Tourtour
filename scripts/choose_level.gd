extends TextureRect

signal level_chosen

@onready var level_2 := %Level2
@onready var level_3 := %Level3

func _ready() -> void:
	Progress.load()
	level_2.disabled = not Progress.level_1_finished
	level_3.disabled = not Progress.level_2_finished

func pick_level(level_id : int) -> void:
	var next_level : Node
	if level_id == 1:
		next_level = load('res://scenes/level1.tscn').instantiate()
	elif level_id == 2:
		next_level = load('res://scenes/level2.tscn').instantiate()
	elif level_id == 3:
		next_level = load('res://scenes/level3.tscn').instantiate()
	else:
		push_error('ERROR ! Switching to unknown level id %d' % [level_id])
		get_tree().quit()
		
	get_tree().root.add_child(next_level)
	emit_signal('level_chosen')


func _on_back_button_up() -> void:
	hide()
