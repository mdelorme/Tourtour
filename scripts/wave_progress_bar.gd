extends TextureProgressBar

@onready var call_wave_button := $'../../HBoxContainer/CallWaveButton'

var fill_texture_1: Texture2D = preload('res://assets/visual/ui/progress_bar_fill_orange.png')
var fill_texture_2: Texture2D = preload('res://assets/visual/ui/progress_bar_fill_blue.png')

func wave_progress(time: float, total_time: float) -> void:
	texture_progress = fill_texture_1
	value = time * 100.0 / total_time
	$Label.text = tr('WAVE_PROGRESS_END_IN') + ' %d s' % [time]
	call_wave_button.disabled = true
	
func wait_for_wave(time: float, total_time: float) -> void:
	texture_progress = fill_texture_2
	value = time * 100 / total_time
	$Label.text = tr('WAVE_PROGRESS_NEXT_WAVE') + ' %d s' % [time]
	call_wave_button.disabled = false
	
func wait_for_end() -> void:
	$Label.text = 'BOSS !'
	value = 0.0
