extends Panel

@export var image : Texture2D
@export var text  : String

enum NotifState {
	Growing,
	Showing,
	On_Display,
	Disappearing
}

var cooldown := 0.0
var state : NotifState

func make_monster_notif(monster_name: String, icon: Texture2D) -> void:
	text = tr(monster_name) + ' ' + tr('NOTIFICATION_ENCOUNTERED') 
	image = icon
	
func _ready() -> void:
	cooldown = Constants.NOTIFICATION_COOLDOWN
	state = NotifState.Growing
	$MarginContainer/HBox/Image.texture = image
	$MarginContainer/HBox/Text.text = text
	
	scale = Vector2(1.0, 0.0)
	$MarginContainer.modulate = Color(0.0, 0.0, 0.0, 0.0)
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), Constants.NOTIFICATION_GROWTH_DURATION)
	tween.tween_property($MarginContainer, "modulate", Color(1.0, 1.0, 1.0, 1.0), Constants.NOTIFICATION_SHOWING_DURATION)
	tween.tween_interval(Constants.NOTIFICATION_COOLDOWN)
	tween.tween_property($MarginContainer, "modulate", Color(0.0, 0.0, 0.0, 0.0), Constants.NOTIFICATION_SHOWING_DURATION)
	tween.tween_property(self, "scale", Vector2(1.0, 0.0), Constants.NOTIFICATION_GROWTH_DURATION)
	tween.tween_callback(queue_free)
	
