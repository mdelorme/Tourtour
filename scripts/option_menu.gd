extends Control

@export var is_modal := false

func _ready() -> void:
	update_controls()
	
func update_controls() -> void:
	if 'master_volume' not in Progress.options:
		Progress.load()
		
	# Setting sliders to the right position
	var master_volume : float = Progress.options['master_volume']
	var music_volume : float = Progress.options['music_volume']
	var effects_volume : float = Progress.options['effects_volume']
	var env_volume : float = Progress.options['env_volume']
	
	var master_bus  := AudioServer.get_bus_index('Master')
	var music_bus   := AudioServer.get_bus_index('Music')
	var effects_bus := AudioServer.get_bus_index('Effects')
	var env_bus     := AudioServer.get_bus_index('Environment')
	
	AudioServer.set_bus_volume_db(master_bus, master_volume)
	AudioServer.set_bus_volume_db(music_bus, music_volume)
	AudioServer.set_bus_volume_db(effects_bus, effects_volume)
	AudioServer.set_bus_volume_db(env_bus, env_volume)
	
	%MasterSlider.value  = master_volume
	%MusicSlider.value   = music_volume
	%EffectsSlider.value = effects_volume
	%EnvSlider.value     = env_volume
	
	# Check box and screen mode
	match DisplayServer.window_get_mode(): # Hard coded ugh !
		DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN: %ScreenModeOptions.select(0)
		DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:  %ScreenModeOptions.select(1)
		DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:   %ScreenModeOptions.select(2)
	%EnableTutorials.button_pressed = Progress.options['tutorials_enabled']
	
	
	
func _process(_delta: float) -> void:
	%ResetTutorialsButton.disabled = (Progress.seen_tutorials == {})
	
func _music_drag_changed(value: float) -> void:
	var bus_id := AudioServer.get_bus_index('Music')
	AudioServer.set_bus_volume_db(bus_id, value)
	AudioServer.set_bus_mute(bus_id, value == -70)


func _effect_drag_ended(_value_changed: bool) -> void:
	$TestSounds/EffectTest.stop()


func _effect_drag_started() -> void:
	$TestSounds/EffectTest.play()


func _effect_drag_changed(value: float) -> void:
	var bus_id := AudioServer.get_bus_index('Effects')
	AudioServer.set_bus_volume_db(bus_id, value)
	AudioServer.set_bus_mute(bus_id, value == -70)


func _env_drag_ended(_value_changed: bool) -> void:
	$TestSounds/EnvTest.stop()


func _env_drag_started() -> void:
	$TestSounds/EnvTest.play()


func _env_drag_changed(value: float) -> void:
	var bus_id := AudioServer.get_bus_index('Environment')
	AudioServer.set_bus_volume_db(bus_id, value)
	AudioServer.set_bus_mute(bus_id, value == -70)


func _master_drag_ended(_value_changed: bool) -> void:
	$TestSounds/EffectTest.stop()
	$TestSounds/EnvTest.stop()


func _master_drag_started() -> void:
	$TestSounds/EffectTest.play()
	$TestSounds/EnvTest.play()


func _master_drag_changed(value: float) -> void:
	var bus_id := AudioServer.get_bus_index('Master')
	AudioServer.set_bus_volume_db(bus_id, value)
	AudioServer.set_bus_mute(bus_id, value == -70)

func _on_cancel_button_pressed() -> void:
	var selected_id : int = %ScreenModeOptions.get_selected_id()
	var mode_selected : String = %ScreenModeOptions.get_item_text(selected_id)
	var screen_mode : String = {'0': 'Fullscreen',
								'1': 'Maximized',
								'2': 'Windowed'}[Progress.options['screen_mode']]

	if mode_selected != screen_mode: 
		change_screen_mode(screen_mode)
		
	close_window()
	
func _on_apply_button_pressed() -> void:
	Progress.options['screen_mode']    = %ScreenModeOptions.selected
	Progress.options['master_volume']  = %MasterSlider.value
	Progress.options['music_volume']   = %MusicSlider.value
	Progress.options['effects_volume'] = %EffectsSlider.value
	Progress.options['env_volume']     = %EnvSlider.value
	Progress.options['tutorials_enabled'] = %EnableTutorials.button_pressed
	Progress.save_progress()
	
	close_window()
	
func close_window() -> void:
	if not is_modal:
		var next_scene : Node = load('res://scenes/main_menu.tscn').instantiate()
		get_tree().root.add_child(next_scene)
		queue_free()
	else:
		hide()


func _on_enable_tutorials_toggled(_toggled_on: bool) -> void:
	pass
	


func _on_reset_progress_button_pressed() -> void:
	%ConfirmationPanel.show()


func _on_reset_tutorials_button_pressed() -> void:
	Progress.seen_tutorials = {}
	Progress.save_progress()


func _cancel_reset() -> void:
	%ConfirmationPanel.hide()


func _confirm_reset_progress() -> void:
	Progress.reset()
	%ConfirmationPanel.hide()

func change_screen_mode(screen_mode: String) -> void:
	var new_window_mode : DisplayServer.WindowMode = DisplayServer.window_get_mode()
	match screen_mode:
		'Fullscreen': new_window_mode = DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
		'Maximized':  new_window_mode = DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED
		'Windowed':   new_window_mode = DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
		
	DisplayServer.window_set_mode(new_window_mode)
		
func _on_screen_mode_changed(index: int) -> void:
	var screen_mode : String = %ScreenModeOptions.get_item_text(index)
	change_screen_mode(screen_mode)


func _on_visibility_changed() -> void:
	if visible:
		update_controls()
