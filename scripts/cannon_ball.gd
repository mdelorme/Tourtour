extends Node2D

var target : Vector2
var damage : int
var speed  : float
var aoe    : int

const explosion := preload("res://scenes/explosion2.tscn")

@onready var coll_shape := $Area2D/CollisionShape
@onready var area       := $Area2D

func _ready() -> void:
	coll_shape.shape.radius = aoe

func init(_target: Vector2, _damage: int, _speed: float, _aoe: int) -> void:
	target = _target
	damage = _damage
	speed  = _speed
	aoe    = _aoe

func _physics_process(delta: float) -> void:
	if target.distance_to(global_position) < speed * delta:
		global_position = target
		explode()
	else:
		var dd := target - global_position
		dd = dd.normalized()
		global_position += dd * speed * delta
		
func explode() -> void:
	var overlapping : Array[Area2D] = area.get_overlapping_areas()
	for over_area in overlapping:
		var en : Enemy = over_area.get_parent() as Enemy
		if not en.immune_to_cannon:
			en.damage(damage)
	var expl := explosion.instantiate()
	expl.play('default')
	get_parent().add_child(expl)
	expl.global_position = target
	
	queue_free()
			
	
	
