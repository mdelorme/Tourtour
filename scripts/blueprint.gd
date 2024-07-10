extends Node2D
class_name Blueprint

const archer_twr_texture : Texture2D = preload("res://assets/visual/archer_tower.png")
const mage_twr_texture   : Texture2D = preload("res://assets/visual/mage_tower.png")
const druid_twr_texture  : Texture2D = preload("res://assets/visual/druid_tower.png")
const cannon_twr_texture : Texture2D = preload("res://assets/visual/cannon_tower.png")

const archer_twr := preload("res://scenes/archer_tower.tscn")
const mage_twr   := preload("res://scenes/mage_tower.tscn")
const druid_twr  := preload("res://scenes/druid_tower.tscn")
const cannon_twr := preload("res://scenes/cannon_tower.tscn")


@onready var archer_twr_ref := $Node2D/ArcherTower
@onready var mage_twr_ref   := $Node2D/MageTower
@onready var druid_twr_ref  := $Node2D/DruidTower
@onready var cannon_twr_ref := $Node2D/CannonTower

var points_circle := PackedVector2Array()

var blocked := false
var tile_coord : Vector2i
var radius : float
var rim_color  : Color
var fill_color : Color
var type : Constants.TowerType

func set_blocked() -> void:
	blocked = true
	$Sprite2D.modulate = Color(1.0, 0.5, 0.5)
	
func set_free() -> void:
	blocked = false
	$Sprite2D.modulate = Color(1.0, 1.0, 1.0)

func select_type(_type: Constants.TowerType) -> void:
	self.type = _type
	match type:
		Constants.TowerType.Archer: 
			$Sprite2D.texture = archer_twr_texture
			rim_color    = Constants.TOWER_COLOR_RIM_ARCHER
			fill_color   = Constants.TOWER_COLOR_ARCHER
			radius       = Constants.TOWER_RANGE_ARCHER
			
		Constants.TowerType.Mage: 
			$Sprite2D.texture = mage_twr_texture
			rim_color    = Constants.TOWER_COLOR_RIM_MAGE
			fill_color   = Constants.TOWER_COLOR_MAGE
			radius       = Constants.TOWER_RANGE_MAGE
			
		Constants.TowerType.Druid: 
			$Sprite2D.texture = druid_twr_texture
			rim_color    = Constants.TOWER_COLOR_RIM_DRUID
			fill_color   = Constants.TOWER_COLOR_DRUID
			radius       = Constants.TOWER_RANGE_DRUID
			
		Constants.TowerType.Cannon: 
			$Sprite2D.texture = cannon_twr_texture
			rim_color    = Constants.TOWER_COLOR_RIM_CANNON
			fill_color   = Constants.TOWER_COLOR_CANNON
			radius       = Constants.TOWER_RANGE_CANNON
	
func recalculate_points() -> void:
	points_circle.clear()
	var da := PI * 2.0 / Constants.DRAW_CIRCLE_NPTS
	for i in range(Constants.DRAW_CIRCLE_NPTS+1):
		var angle := i*da
		points_circle.append(radius * Vector2(cos(angle), sin(angle)) 
							+ Vector2(Constants.HALF_TILE, Constants.HALF_TILE))

func _process(_delta: float) -> void:
	queue_redraw()
		
func _draw() -> void:
	recalculate_points()
	var c1: Color
	var c2: Color
	if blocked:
		c1 = Color(1.0, 0.7, 0.7, 0.5)
		c2 = Color(1.0, 0.5, 0.5, 0.8)
	else:
		c1 = fill_color
		c2 = rim_color
		
	var colors := PackedColorArray([c1])
	draw_polygon(points_circle, colors) 
	for i in range(Constants.DRAW_CIRCLE_NPTS):
		draw_line(points_circle[i], points_circle[i+1], c2, 2.0)
		
func create_tower_instance() -> Tower:
	var instance : Tower
	match type:
		Constants.TowerType.Archer: instance = archer_twr.instantiate()
		Constants.TowerType.Mage:   instance = mage_twr.instantiate()
		Constants.TowerType.Druid:  instance = druid_twr.instantiate()
		Constants.TowerType.Cannon: instance = cannon_twr.instantiate()
	return instance
