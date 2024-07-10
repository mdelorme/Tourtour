extends Node2D

@onready var particles := $CPUParticles2D


var points_circle := PackedVector2Array()
var cooldown : float

func _ready() -> void:
	cooldown = Constants.ICE_EXPLOSION_COOLDOWN
	
	points_circle.clear()
	var da := PI * 2.0 / Constants.DRAW_CIRCLE_NPTS
	for i in range(Constants.DRAW_CIRCLE_NPTS+1):
		var angle := i*da
		points_circle.append(Constants.SLOWDOWN_RADIUS * Vector2(cos(angle), sin(angle)) 
							+ Vector2(Constants.HALF_TILE, Constants.HALF_TILE))
							
	particles.emission_sphere_radius = Constants.SLOWDOWN_RADIUS


func _process(delta: float) -> void:
	cooldown = max(0.0, cooldown - delta)
	
	if cooldown == 0.0:
		queue_free()    
		
func _draw() -> void:
	var colors := PackedColorArray([Constants.COLOR_ICE_EXPLOSION])
	draw_polygon(points_circle, colors) 
