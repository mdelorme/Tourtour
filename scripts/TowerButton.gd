extends Node2D

signal selected_button
signal deselected_button

@export_global_file("*.png") var texture_normal
@export_global_file("*.png") var texture_active
@export_global_file("*.png") var texture_disabled
@export var button_name : String

enum ButtonState {Normal, Active, Disabled}

var state := ButtonState.Disabled

func _ready() -> void:
	$NormalState.texture   = load(texture_normal)
	$ActiveState.texture   = load(texture_active)
	$DisabledState.texture = load(texture_disabled)
	
	state = ButtonState.Normal
	
func set_state(new_state : ButtonState) -> void:
	if new_state == state:
		return
		
	var old_state := state
	state = new_state
	if old_state == ButtonState.Normal and new_state == ButtonState.Active:
		emit_signal('selected_button')
		print('Selected button ', button_name)
	elif old_state == ButtonState.Active and new_state == ButtonState.Normal:
		emit_signal('deselected_button')
		print('De-selected button ', button_name)
	
	match new_state:
		ButtonState.Normal: 
			$NormalState.visible = true
			$DisabledState.visible = false
			$ActiveState.visible = false
		ButtonState.Active:
			$NormalState.visible = false
			$DisabledState.visible = false
			$ActiveState.visible = true    
		ButtonState.Disabled:
			$NormalState.visible = false
			$DisabledState.visible = true
			$ActiveState.visible = false        

func _on_input_event(viewport, event, shape_idx):
	if state == ButtonState.Disabled:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if state == ButtonState.Active:
				set_state(ButtonState.Normal)
			elif state == ButtonState.Normal:
				set_state(ButtonState.Active)
