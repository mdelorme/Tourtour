extends Control

var codex_scene := preload('res://scenes/codex.tscn')
@onready var codex := $Codex
@onready var options := $OptionsWindow

var ui_cooldown := 0.0

func _ready() -> void:
	codex.is_modal = true
	options.is_modal = true
	
	
func _process(delta: float) -> void:
	ui_cooldown = max(0.0, ui_cooldown - delta)
	
func _input(event: InputEvent) -> void:
	if event.is_action_released('pause') and visible and ui_cooldown == 0.0:
		accept_event()
		unpause()

func _on_return_button_pressed() -> void:
	unpause()
	
func unpause() -> void:
	get_tree().paused = false
	visible = false

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_back_to_menu_button_pressed() -> void:
	# Maybe add a confirmation here ?
	get_tree().paused = false
	get_tree().change_scene_to_file('res://scenes/main_menu.tscn')


func _on_codex_button_pressed() -> void:
	Progress.rebuild_codex_ref()
	codex.visible = true


func _on_codex_visibility_changed() -> void:
	ui_cooldown = Constants.UI_COOLDOWN


func _on_options_button_pressed() -> void:
	options.visible = true
