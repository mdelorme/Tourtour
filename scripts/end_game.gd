extends Control

@onready var opacifier: ColorRect = $Opacifier
@onready var ch_1: TextureRect = $Ch1
@onready var ch_2: TextureRect = $Ch2
@onready var ch_3: TextureRect = $Ch3
@onready var label_ch1: Label = $Ch1/LabelCh1
@onready var label_ch2: Label = $Ch2/LabelCh2
@onready var label_ch3_1: Label = $Ch3/LabelCh3_1
@onready var label_ch3_2: Label = $Ch3/LabelCh3_2
@onready var main_background: TextureRect = $MainBackground

const DURATION_OPACIFIER_FADE_OUT := 3.0
const DURATION_OPACIFIER_FADE_IN  := 3.0
const DURATION_LONG_PAUSE := 10.0
const DURATION_SHORT_PAUSE := 1
const DURATION_CH_1_FADE_IN := 1.0
const DURATION_LB_1_FADE_IN := 0.5
const DURATION_LB_1_FADE_OUT := 0.5
const DURATION_CH_1_FADE_OUT := 1.0
const DURATION_CH_2_FADE_IN := 1.0
const DURATION_LB_2_FADE_IN := 0.5
const DURATION_LB_2_FADE_OUT := 0.5
const DURATION_CH_2_FADE_OUT := 1.0
const DURATION_CH_3_FADE_IN := 1.0
const DURATION_LB_3_FADE_IN := 0.5
const DURATION_LB_3_FADE_OUT := 0.5
const DURATION_CH_3_FADE_OUT := 1.0
const DURATION_FINAL_FADE_IN := 2.0


const COLOR_OPAQUE      := Color(1.0, 1.0, 1.0, 1.0)
const COLOR_TRANSPARENT := Color(1.0, 1.0, 1.0, 0.0)

var tween : Tween
var speeding_up : bool
var slowing_steps : Array

func _ready() -> void:
	speeding_up = false
	get_tree().paused = false
	
	tween = get_tree().create_tween()
	#tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	opacifier.modulate    = COLOR_OPAQUE
	label_ch1.modulate   = COLOR_TRANSPARENT
	label_ch2.modulate   = COLOR_TRANSPARENT
	label_ch3_1.modulate = COLOR_TRANSPARENT
	label_ch3_2.modulate = COLOR_TRANSPARENT
	ch_1.modulate = COLOR_TRANSPARENT
	ch_2.modulate = COLOR_TRANSPARENT
	ch_3.modulate = COLOR_TRANSPARENT
	
	slowing_steps = [4, 12, 21, 29]
	
	# Ch 1
	tween.tween_interval(DURATION_SHORT_PAUSE)
	tween.tween_property(ch_1, 'modulate', COLOR_OPAQUE, 0.0)
	tween.tween_property(opacifier, 'modulate', COLOR_TRANSPARENT, DURATION_OPACIFIER_FADE_OUT)
	tween.tween_interval(DURATION_SHORT_PAUSE)
	tween.tween_property(label_ch1, 'modulate', COLOR_OPAQUE, DURATION_LB_1_FADE_IN)
	tween.tween_interval(DURATION_LONG_PAUSE)
	tween.tween_property(label_ch1, 'modulate', COLOR_TRANSPARENT, DURATION_LB_1_FADE_OUT)
	tween.tween_property(opacifier, 'modulate', COLOR_OPAQUE, DURATION_OPACIFIER_FADE_IN)
	
	# Ch 2
	tween.tween_property(ch_2, 'modulate', COLOR_OPAQUE, 0.0)
	tween.tween_property(opacifier, 'modulate', COLOR_TRANSPARENT, DURATION_OPACIFIER_FADE_OUT)
	tween.tween_interval(DURATION_SHORT_PAUSE)
	tween.tween_property(label_ch2, 'modulate', COLOR_OPAQUE, DURATION_LB_2_FADE_IN)
	tween.tween_interval(DURATION_LONG_PAUSE)
	tween.tween_property(label_ch2, 'modulate', COLOR_TRANSPARENT, DURATION_LB_2_FADE_OUT)
	tween.tween_property(opacifier, 'modulate', COLOR_OPAQUE, DURATION_OPACIFIER_FADE_IN)
	
	# Ch 3
	tween.tween_property(ch_3, 'modulate', COLOR_OPAQUE, 0.0)
	tween.tween_property(opacifier, 'modulate', COLOR_TRANSPARENT, DURATION_OPACIFIER_FADE_OUT)
	tween.tween_interval(DURATION_SHORT_PAUSE)
	tween.tween_property(label_ch3_1, 'modulate', COLOR_OPAQUE, DURATION_LB_3_FADE_IN)
	tween.tween_interval(DURATION_LONG_PAUSE)
	tween.tween_property(label_ch3_2, 'modulate', COLOR_OPAQUE, DURATION_LB_3_FADE_IN)
	tween.tween_interval(DURATION_LONG_PAUSE)
	tween.tween_property(label_ch3_1, 'modulate', COLOR_TRANSPARENT, DURATION_LB_3_FADE_OUT)
	tween.tween_property(label_ch3_2, 'modulate', COLOR_TRANSPARENT, DURATION_LB_3_FADE_OUT)
	tween.tween_property(opacifier, 'modulate', COLOR_OPAQUE, DURATION_OPACIFIER_FADE_IN)
	tween.tween_interval(DURATION_LONG_PAUSE)
	tween.tween_property(main_background, 'modulate', COLOR_OPAQUE, 0.0)
	tween.tween_property(opacifier, 'modulate', COLOR_TRANSPARENT, DURATION_FINAL_FADE_IN)
	tween.tween_callback(roll_credits)
	
func _physics_process(delta: float) -> void:
	if speeding_up:
		tween.custom_step(delta*5)
		if $Credits and $Credits.visible:
			$Credits.tween.custom_step(delta*5)
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			speeding_up = true
			$TextureRect.visible = true
		elif event.is_released():
			speeding_up = false
			$TextureRect.visible = false
	
func roll_credits() -> void:
	$Credits.show()


func _on_tree_exiting() -> void:
	$AudioStreamPlayer.stop()
