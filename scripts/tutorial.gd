extends Panel
class_name Tutorial

signal tutorial_finished

enum TriggerType {
	AUTO,
	ENCOUNTER,
}

@export var trigger_type : TriggerType = TriggerType.AUTO
@export var encounter_name := 'goblin'
@export var unique_id : String

func show_tutorial() -> void:
	visible = true
	get_tree().paused = true
	
func _exit_tree() -> void:
	get_tree().paused = false

func _on_button_pressed() -> void:
	if $CheckBox.button_pressed:
		Progress.options['tutorials_enabled'] = false
		Progress.save_progress()
	queue_free()
