extends TextureRect

var selected := 0
var nlabels  := 0
var glow     := 0.0
@onready var labels := [$MarginContainer/VBoxContainer/NewGameLabel,
						$MarginContainer/VBoxContainer/OptionsLabel,
						$MarginContainer/VBoxContainer/CodexLabel,
						$MarginContainer/VBoxContainer/CreditsLabel,
						$MarginContainer/VBoxContainer/ExitGameLabel]
						
var active := false
var mouse_on_label := false
	
func _ready() -> void:
	nlabels = len(labels)
	transition_in()
	
	if Progress.game_just_started:
		Progress.load()
		Progress.game_just_started = false
	
func activate() -> void:
	active = true

func _process(delta: float) -> void:
	# Lazy shit
	$Label.modulate = $MarginContainer.modulate
	
	if not active:
		return
		
	if Input.is_action_just_pressed('ui_down'):
		select_label(selected+1)
	if Input.is_action_just_pressed('ui_up'):
		select_label(selected-1)
	if Input.is_action_just_pressed('ui_accept'):
		transition()
	if Input.is_action_just_pressed('menu_mouse'):
		if not $AudioStreamPlayer2D.playing:
			$AudioStreamPlayer2D.play()
		if mouse_on_label:
			transition()
		
	glow += delta
	
	
	
func select_label(label_id: int) -> void:
	if not active:
		return
		
	var last := selected
	selected = (label_id + nlabels) % nlabels
	
	var last_label : Label = labels[last]
	var new_label  : Label = labels[selected]
	
	last_label.set('theme_override_colors/font_color', Constants.FONT_COLOR_UNSELECTED)
	new_label.set('theme_override_colors/font_color',  Constants.FONT_COLOR_SELECTED)
	last_label.set('theme_override_constants/outline_size', Constants.FONT_OUTLINE_UNSELECTED)
	new_label.set('theme_override_constants/outline_size', Constants.FONT_OUTLINE_SELECTED)

func validate_choice() -> void:
	const SELECTED_NEWGAME   := 0
	const SELECTED_OPTIONS   := 1
	const SELECTED_CODEX     := 2
	const SELECTED_CREDITS   := 3
	const SELECTED_EXIT      := 4
	var next_scene : Node = null
	match selected:
		SELECTED_EXIT:      quit()
		SELECTED_NEWGAME:   next_scene = new_game()
		SELECTED_OPTIONS:   $OptionsWindow.show()
		SELECTED_CODEX:     $Codex.show()
		SELECTED_CREDITS:   $Credits.show() #next_scene = load('res://scenes/credits.tscn').instantiate()
	if next_scene : 
		get_tree().root.add_child(next_scene)
		queue_free()
	
func transition() -> void:
	active = false
	var tween := get_tree().create_tween()
	tween.tween_property($MarginContainer, "modulate", Color(1.0, 1.0, 1.0, 0.0), Constants.MENU_TRANSITION_DURATION)
	tween.tween_interval(0.2)
	tween.tween_callback(validate_choice)
	
func transition_in() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property($MarginContainer, "modulate", Color(1.0, 1.0, 1.0, 1.0), Constants.MENU_TRANSITION_DURATION)
	tween.tween_callback(activate)


func _on_mouse_entered() -> void:
	if active:
		mouse_on_label = true

func _on_mouse_exited() -> void:
	if active:
		mouse_on_label = false
	
func new_game() -> Node:
	var next_scene : Node
	if Progress.level_1_finished == false:
		next_scene = load('res://scenes/level1.tscn').instantiate()
		#get_tree().change_scene_to_file('res://scenes/level1.tscn')
	else:
		next_scene = null
		$ChooseLevel.show()
	return next_scene
	
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Progress.save_progress()

func quit() -> void:
	Progress.save_progress()
	get_tree().quit()


func _on_level_chosen() -> void:
	queue_free()
