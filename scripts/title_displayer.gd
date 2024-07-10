extends Control


@onready var slide_in_bg  := $SlideInBackground
@onready var slide_in_txt := $SlideInLevelID
@onready var fade_out_bg  := $FadeOutBackground

var finished: bool = false
	
func display_title() -> void:
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	
	var txt_x : int = get_viewport_rect().size.x * 0.5 - slide_in_txt.size.x * 0.5
	tween.tween_interval(Constants.TITLE_DISPLAYER_INIT_WAIT)
	tween.tween_property(slide_in_bg, 'position', Vector2(-100.0, slide_in_bg.position.y), Constants.TITLE_DISPLAYER_SLIDE_IN_DURATION)
	tween.tween_interval(Constants.TITLE_DISPLAYER_INTER_WAIT)
	tween.tween_property(slide_in_txt, 'position', Vector2(txt_x, slide_in_txt.position.y), Constants.TITLE_DISPLAYER_SLIDE_IN_DURATION)
	tween.tween_interval(Constants.TITLE_DISPLAYER_WAIT_TIME)
	tween.tween_property(fade_out_bg, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Constants.TITLE_DISPLAYER_FADE_OUT_DURATION)
	tween.tween_interval(Constants.TITLE_DISPLAYER_WAIT_TIME)
	tween.tween_property(slide_in_txt, 'position', Vector2(500, slide_in_txt.position.y), Constants.TITLE_DISPLAYER_SLIDE_IN_DURATION)
	tween.tween_property(slide_in_bg, 'position', Vector2(-700, slide_in_bg.position.y), Constants.TITLE_DISPLAYER_SLIDE_IN_DURATION)
	tween.tween_property(self, 'finished', true, 0.0)
