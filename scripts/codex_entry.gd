extends MarginContainer

signal entry_clicked

var settings: LabelSettings
var codex_entry: String
var focused: bool

func _ready() -> void:
	settings = $Label.get_label_settings()
	unfocus()

func init(text: String, entry: String) -> void:
	$Label.text = text
	codex_entry = entry

func _on_mouse_entered() -> void:
	if not focused:
		$Label.set('theme_override_colors/font_color', Color('#ff5342'))

func _on_mouse_exited() -> void:
	if not focused:
		$Label.set('theme_override_colors/font_color', Color('#d0670a'))
	
func focus() -> void:
	$Label.set('theme_override_colors/font_color', Color('#d0d50a'))
	focused = true
	
func unfocus() -> void:
	focused = false
	_on_mouse_exited()


func _on_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var evt : InputEventMouseButton = event
		if evt.button_index == MOUSE_BUTTON_LEFT and evt.pressed:
			emit_signal('entry_clicked', codex_entry)
