extends Control

signal start_over

@onready var panel := $MarginContainer/Panel
@onready var txt1  := $MarginContainer/Panel/GameOverTxt
@onready var txt2  := $MarginContainer/Panel/MonstersHaveWonTxt
@onready var retry_btn := $MarginContainer/Panel/RetryButton
@onready var back_btn  := $MarginContainer/Panel/BackToMenuButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var elems := [panel, txt2, retry_btn, back_btn]
	for e: Node in elems:
		e.modulate = Color(0.0, 0.0, 0.0, 0.0)
	
	txt1.text = ''
	
	var tween := create_tween()
	tween.tween_property(panel, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Constants.GAMEOVER_INIT_SPEED)
	tween.tween_property(txt1, 'text', 'GAME OVER', Constants.GAMEOVER_TXT_SPEED)
	tween.tween_property(txt2, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Constants.GAMEOVER_TXT2_SPEED)
	tween.parallel().tween_property(retry_btn, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Constants.GAMEOVER_TXT2_SPEED)
	tween.parallel().tween_property(back_btn, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Constants.GAMEOVER_TXT2_SPEED)

func _on_retry_button_pressed() -> void:
	emit_signal('start_over')

func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/main_menu.tscn')
