extends Node2D
class_name Tower

signal play_sound(sound_id: Constants.GameSoundId)

const arrow          := preload("res://scenes/arrow.tscn")
const cannon_ball    := preload("res://scenes/cannon_ball.tscn")
const ice_projectile := preload("res://scenes/ice_projectile.tscn")

var fire_cooldown : float
var fire_range : float
var damage : int
var aoe : float
var slowdown : float = 1.0
@export var type : Constants.TowerType
@export var active : bool = true
@export var projectile_speed : float 
@onready var projectiles := $Projectiles
@onready var druid_line : Line2D = $Line2D

@export var firing_sound : Constants.GameSoundId = Constants.GameSoundId.Arrow

var cost : int
var collision_shape: CircleShape2D
var cooldown : float

var enemy_list : Array[Enemy] = []

func _ready() -> void:
	cooldown = 0.0
	match type:
		Constants.TowerType.Archer: 
			cost          = Constants.TOWER_PRICE_ARCHER
			fire_cooldown = Constants.TOWER_FIRE_RATE_ARCHER
			fire_range    = Constants.TOWER_RANGE_ARCHER
			damage        = Constants.TOWER_DAMAGE_ARCHER
		Constants.TowerType.Mage:   
			cost          = Constants.TOWER_PRICE_MAGE
			fire_cooldown = Constants.TOWER_FIRE_RATE_MAGE
			fire_range    = Constants.TOWER_RANGE_MAGE
			damage        = Constants.TOWER_DAMAGE_MAGE
			slowdown      = Constants.TOWER_SLOWDOWN_MAGE
		Constants.TowerType.Druid:  
			cost          = Constants.TOWER_PRICE_DRUID
			fire_cooldown = Constants.TOWER_FIRE_RATE_DRUID
			fire_range    = Constants.TOWER_RANGE_DRUID
			damage        = Constants.TOWER_DAMAGE_DRUID
		Constants.TowerType.Cannon: 
			cost          = Constants.TOWER_PRICE_CANNON
			fire_cooldown = Constants.TOWER_FIRE_RATE_CANNON
			fire_range    = Constants.TOWER_RANGE_CANNON
			damage        = Constants.TOWER_DAMAGE_CANNON
			aoe           = Constants.TOWER_AOE_CANNON
			
	collision_shape = $Area2D/CollisionShape2D.shape as CircleShape2D
	collision_shape.radius = fire_range
			
func _physics_process(delta: float) -> void:
	if not active:
		return
		
	if cooldown == 0.0 and len(enemy_list) > 0:
		fire()
		cooldown = fire_cooldown
	else:
		var can_fire_druid := false
		for en in enemy_list:
			if en.can_be_electrocuted:
				can_fire_druid = true
				break
		druid_line.points = []
		if type == Constants.TowerType.Druid and can_fire_druid:
			rebuild_druid_line()
		cooldown = max(0.0, cooldown - delta)

func find_insert_position(advancement: float) -> int:
	var L := 0
	var R := enemy_list.size()
	
	while L < R-1:
		var mid := (L+R)/2
		var adv := enemy_list[mid].get_advancement()
		if adv > advancement:
			R = mid
		else:
			L = mid
	return L
	

func _on_area_entered(area: Area2D) -> void:    
	if not active:
		return
		
	# Be careful here ! 
	# Only enemies should be monitorable, otherwise we might end up with
	# other things being registered as enemies
	if area.owner is Enemy:
		var node : Enemy = area.owner as Enemy
		enemy_list.append(node)
		enemy_list.sort_custom(func(a: Enemy, b: Enemy) -> bool: return a.advancement > b.advancement)
		if type == Constants.TowerType.Druid and not node.is_electrified:
			node.is_electrified = true
	
func _on_area_exited(area: Area2D) -> void:
	if not active:
		return
		
	if not area.get_parent() is Enemy:
		return
		
	var node : Enemy = area.get_parent() as Enemy
	enemy_list.erase(node)
	#enemy_list.sort_custom(func(a: Enemy, b: Enemy) -> bool: return a.get_advancement() > b.get_advancement())
	if type == Constants.TowerType.Druid and node.is_electrified:
		node.is_electrified = false
	
func fire() -> void:
	if not active:
		return
		
	match type:
		Constants.TowerType.Archer: fire_archers()
		Constants.TowerType.Mage:   fire_mages()
		Constants.TowerType.Druid:  fire_druids()
		Constants.TowerType.Cannon: fire_cannons()
	emit_signal('play_sound', firing_sound)
		
func fire_archers() -> void:
	if not active:
		return
	
	# Skipping immune to archers enemies
	var cur_target := 0
	while cur_target < len(enemy_list) and enemy_list[cur_target].immune_to_arrows:
		cur_target += 1
	if cur_target == len(enemy_list):
		return
		
	var target := enemy_list[cur_target]
	var new_arrow := arrow.instantiate()
	new_arrow.init(target, damage, projectile_speed)
	projectiles.add_child(new_arrow)
	
func fire_mages() -> void:
	if not active:
		return
	
	var target := enemy_list[0].global_position
	var new_ice_projectile := ice_projectile.instantiate()
	new_ice_projectile.init(target, damage, projectile_speed, slowdown, Constants.SLOWDOWN_COOLDOWN)
	projectiles.add_child(new_ice_projectile)
	
func fire_druids() -> void:
	if not active:
		return
	
	var dmg := damage
	for target in enemy_list:
		if target.can_be_electrocuted:
			target.damage(dmg)
			dmg -= 1
		if dmg == 0:
			break
	
func fire_cannons() -> void:
	if not active:
		return
	
	# Skipping immune to cannon enemies
	var cur_target := 0
	while cur_target < len(enemy_list) and enemy_list[cur_target].immune_to_cannon:
		cur_target += 1
	if cur_target == len(enemy_list):
		return
		
	var target := enemy_list[cur_target].global_position
	var new_cannon_ball := cannon_ball.instantiate()
	new_cannon_ball.init(target, damage, projectile_speed, aoe)
	projectiles.add_child(new_cannon_ball)
	
func rebuild_druid_line() -> void:
	var pts := [Vector2(8, 8)]
	var dmg := damage
	for target in enemy_list:
		if target.can_be_electrocuted:
			var next_pos : Vector2 = Vector2(target.global_position - global_position)
			if dmg > 0:
				pts.append(next_pos)
				dmg -= 1
				target.toggle_electrocute(true)
			else:
				target.toggle_electrocute(false)
	druid_line.points = pts
