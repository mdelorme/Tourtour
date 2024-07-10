extends TextureRect

@onready var entry_list := $MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/ElementPanel/MarginContainer/EntryList

@onready var elt_name  := $MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/DescriptionPanel/MarginContainer/DescriptionTable/ElementName
@onready var elt_image := $MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/DescriptionPanel/MarginContainer/DescriptionTable/Image
@onready var elt_desc1 := $MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/DescriptionPanel/MarginContainer/DescriptionTable/Description1
@onready var elt_desc2 := $MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/DescriptionPanel/MarginContainer/DescriptionTable/Description2
@onready var elt_desc3 := $MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/DescriptionPanel/MarginContainer/DescriptionTable/Description3
@onready var elt_desc4 := $MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/DescriptionPanel/MarginContainer/DescriptionTable/Description4
@onready var elt_desc5 := $MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/DescriptionPanel/MarginContainer/DescriptionTable/Description5

const CodexEntry := preload('res://scenes/codex_entry.tscn')

var entries := {}
var nodes := []
@export var is_modal := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build_codex()
	
func build_codex() -> void:
	if not entry_list:
		return
		
	Progress.rebuild_codex_ref()
	#var tween := get_tree().create_tween()
	#tween.tween_property($Opacifier, "modulate", Color(0.0, 0.0, 0.0, 0.0), Constants.MENU_TRANSITION_DURATION)
	
	# Reading entries in the codex file
	var file := FileAccess.open("res://codex.json", FileAccess.READ)
	var file_content := file.get_as_text()
	var json := JSON.new()
	var error := json.parse(file_content)
	if error == OK:
		entries = json.data['entries']
	else:
		print('JSON parse error : ', json.get_error_message(), ' in codex at line ', json.get_error_line())
		return
		
	for c in entry_list.get_children():
		c.queue_free()
	nodes.clear()
		
	# Now populating the container
	for key: String in entries:
		# Entry is active
		if Progress.codex_ref_table[key]:
			var entry_node := CodexEntry.instantiate()
			var entry : Dictionary = entries[key]
			entry_node.init(entry['name'], key)
			entry_list.add_child(entry_node) 
			entry_node.connect('entry_clicked', entry_clicked)
			nodes.append(entry_node)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_cancel'):
		go_back()
		
func go_back() -> void:
	if not is_modal:
		var next_scene : Node = load('res://scenes/main_menu.tscn').instantiate()
		get_tree().root.add_child(next_scene)
		queue_free()
	else:
		visible = false
		
func entry_clicked(key: String) -> void:
	# Setting the colors and everything
	for n: Node in nodes:
		if n.codex_entry == key:
			n.focus()
		else:
			n.unfocus()
	
	# Filling out the fields
	var entry : Dictionary = entries[key]
	elt_name.text = entry['name']
	var img_size : int = entry['img_size']
	elt_image.texture = load(entry['image'])
	elt_image.size = Vector2(img_size, img_size)
	elt_desc1.text = entry['description']
	var type : String = entry['type']
	if type == 'Enemy':
		var loaded_entry := load(entry['scene'])
		print(loaded_entry)
		var scene : Enemy = loaded_entry.instantiate()
		elt_desc2.text = 'Life : %d' % [scene.life]
		elt_desc3.text = 'Speed : %d' % [scene.speed]
		elt_desc2.visible = true
		elt_desc3.visible = true
		if scene.bounty > 0:
			elt_desc4.text = 'Reward : %d' % [scene.bounty]
			elt_desc4.visible = true
		else:
			elt_desc4.text = ''
			elt_desc4.visible = false
		if 'note' in entry:
			elt_desc5.text = 'Special : ' + entry['note']
			elt_desc5.visible = true
		else:
			elt_desc5.text = ''
			elt_desc5.visible = false
		scene.queue_free()
	else:
		elt_desc2.text = ''
		elt_desc3.text = ''
		elt_desc4.text = ''
		elt_desc5.text = ''
		elt_desc2.visible = false
		elt_desc3.visible = false
		elt_desc4.visible = false
		elt_desc5.visible = false


func _on_visibility_changed() -> void:
	if visible:
		build_codex()
