extends Node2D


var target            : Vector2
var damage            : int
var speed             : float
var slowdown          : float
var slowdown_cooldown : float

var explosion := preload("res://scenes/ice_explosion.tscn")


@onready var coll_shape := $Area2D/CollisionShape
@onready var area       := $Area2D
@onready var particles  := $CPUParticles2D

func _ready() -> void:
	coll_shape.shape.radius = Constants.SLOWDOWN_RADIUS

func init(_target: Vector2, _damage: int, _speed: float, _slowdown: float, _slowdown_cooldown: float) -> void:
	target            = _target
	damage            = _damage
	speed             = _speed
	slowdown          = _slowdown
	slowdown_cooldown = _slowdown_cooldown

func _physics_process(delta: float) -> void:
	if target.distance_to(global_position) < speed * delta:
		global_position = target
		explode()
	else:
		var dd := target - global_position
		particles.direction = -dd
		dd = dd.normalized()
		global_position += dd * speed * delta
		
func explode() -> void:
	var overlapping : Array[Area2D] = area.get_overlapping_areas()
	for over_area in overlapping:
		if over_area.owner is Enemy:
			var en : Enemy = over_area.get_parent() as Enemy
			en.apply_slowdown(slowdown, slowdown_cooldown)
			en.damage(damage)
	
	var expl := explosion.instantiate()
	get_parent().add_child(expl)
	expl.global_position = target
	
	queue_free()
			
	
	
