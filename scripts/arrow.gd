extends Node2D

var target : Enemy
var damage : int
var speed  : float

@onready var animation := $Animation

func _ready() -> void:
	pass
	
func init(_target: Enemy, _damage: int, _speed: float) -> void:
	self.target = _target
	self.damage = _damage
	self.speed  = _speed

func _physics_process(delta: float) -> void:
	if not target:
		queue_free()
		return
	
	var tp := target.global_position
	if tp.distance_to(global_position) < delta * speed:
		if not target.immune_to_arrows:
			target.damage(damage)
		queue_free()
	else:
		var dd := tp - global_position
		dd = dd.normalized() * speed * delta
		position += dd
		
		if abs(dd.x) > abs(dd.y):
			animation.play('horizontal')
			animation.flip_h = (dd.x < 0)
		else:
			animation.play('vertical')
			animation.flip_v = (dd.y < 0)
