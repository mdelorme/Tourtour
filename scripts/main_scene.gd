extends Node2D

# UI Nodes
@onready var lives_label   := $CanvasLayer/VBoxContainer/TopContainer/HBoxContainer/LivesLabel
@onready var gold_label    := $CanvasLayer/VBoxContainer/TopContainer/HBoxContainer/GoldLabel
@onready var arc_twr_btn   := $CanvasLayer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/ArcherTowerButton
@onready var mag_twr_btn   := get_node_or_null('CanvasLayer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/MageTowerButton')
@onready var can_twr_btn   := get_node_or_null('CanvasLayer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/CannonTowerButton')
@onready var drd_twr_btn   := get_node_or_null('CanvasLayer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/DruidTowerButton')
@onready var notif_box     := $CanvasLayer/NotificationBox
@onready var victory_panel := $CanvasLayer/VictoryPanel
@onready var call_wave_btn := %CallWaveButton

@onready var title_displayer := $CanvasLayer/TitleDisplayer

@onready var pause_menu  := $CanvasLayer/PauseMenu

# Game nodes
@onready var main_scene  := $MainScene
@onready var enemy_list  := $MainScene/EnemyList
@onready var trajectory  := $MainScene/EnemyTrajectory
@onready var obstacles   := $MainScene/LevelObstacles
@onready var towers      := $MainScene/Towers
@onready var spawn       := %Spawn

# Audio nodes
@onready var sound_manager := $SoundManager

# Shaking and stuff
@onready var noise := FastNoiseLite.new()
@onready var scene := $MainScene

# Wave indicator
@onready var wave_indicator := %NextWaveIndicator

# Tutorial
@onready var tutorials := %Tutorials

const blueprint    := preload('res://scenes/blueprint.tscn')
const Notification := preload('res://scenes/notification.tscn')
const GameOver     := preload('res://scenes/game_over.tscn')
const Explosion    := preload('res://scenes/explosion2.tscn')

@export var next_level : String
@export var archer_tower_enabled : bool
@export var mage_tower_enabled : bool
@export var druid_tower_enabled : bool
@export var cannon_tower_enabled : bool
@export var cur_level : int
@export var starting_gold : int
@export var starting_life : int
@export var debug_level : bool

# Player info
var lives : int
var gold  : int
var selection : int

var shaking_time := 0.0
var global_timer := 0.0

# Misc
var random_obstacle : TileData
var tower_positions := {}
var show_title : bool = true

var ui_cooldown := 0.0

# Speed
var speed_modifier := 1.0
var speed_accel := 2.0
var speed_decel := 0.5
const min_speed := 0.25
const max_speed := 4.0

var giga_explosions_left := Constants.GIGA_EXPLOSION_COUNT

func _ready() -> void:
	lives = starting_life
	gold  = starting_gold
	lives_label.text = str(lives)
	gold_label.text  = str(gold)
	
	var tween := get_tree().create_tween()
	%LevelMusic.volume_db = -100.0
	tween.tween_property(%LevelMusic, 'volume_db', 0.0, 10.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	for i in range(30*30):
		var ii : int = i/30
		var ij : int = i%30
		var td : TileData = obstacles.get_cell_tile_data(0, Vector2i(ii, ij))
		if td != null:
			random_obstacle = td
			break
			
	# Filling out info labels
	var get_fire_rate_indicator := func(fire_rate: float) -> String:
		if fire_rate == 0.0:
			return tr('FIRE_INSTANT')
		elif fire_rate < 1.0:
			return tr('FIRE_FAST')
		elif fire_rate < 4.0:
			return tr('FIRE_SLOW')
		else:
			return tr('FIRE_VERY_SLOW')
			
	var label: Label
	# Archers
	label = find_child('ArchersCostLabel')
	label.text = '%d' % Constants.TOWER_PRICE_ARCHER
	label = find_child('ArchersFireRateLabel')
	label.text = get_fire_rate_indicator.call(Constants.TOWER_FIRE_RATE_ARCHER)
	label = find_child('ArchersDamageLabel')
	label.text = '%d' % Constants.TOWER_DAMAGE_ARCHER
	
	# Mages
	label = find_child('MagesCostLabel')
	label.text = '%d' % Constants.TOWER_PRICE_MAGE
	label = find_child('MageFireRateLabel')
	label.text = get_fire_rate_indicator.call(Constants.TOWER_FIRE_RATE_MAGE)
	label = find_child('MageDamageLabel')
	label.text = '%d' % Constants.TOWER_DAMAGE_MAGE
	
	# Druids
	label = find_child('DruidsCostLabel')
	label.text = '%d' % Constants.TOWER_PRICE_DRUID
	label = find_child('DruidsFireRateLabel')
	label.text = get_fire_rate_indicator.call(Constants.TOWER_FIRE_RATE_DRUID)
	label = find_child('DruidsDamageLabel')
	label.text = '%d' % Constants.TOWER_DAMAGE_DRUID
	
	# Cannons
	label = find_child('CannonsCostLabel')
	label.text = '%d' % Constants.TOWER_PRICE_CANNON
	label = find_child('CannonsFireRateLabel')
	label.text = get_fire_rate_indicator.call(Constants.TOWER_FIRE_RATE_CANNON)
	label = find_child('CannonsDamageLabel')
	label.text = '%d' % Constants.TOWER_DAMAGE_CANNON
	
	check_buttons_availability()
	
	# Tweening start animation
	if show_title:
		title_displayer.display_title()
		show_title = false
		
	match cur_level:
		1: Progress.level_1_started = true
		2: Progress.level_2_started = true
		3: Progress.level_3_started = true
	Progress.save_progress()
	
	update_wave_indicator()
			
	# Unpausing the game
	get_tree().paused = false
	get_tree().set_current_scene(self)
	   
func _process(delta: float) -> void:
	if not %TitleDisplayer.finished:
		return
		
	delta *= speed_modifier
	
	check_buttons_availability()
	update_wave_indicator()
	
	ui_cooldown = max(0.0, ui_cooldown - delta)
	
	global_timer += delta
	
	# Shaking the screen if necessary
	#shaking_time = 100.0
	if shaking_time > 0.0:
		if shaking_time < delta:
			position = Vector2(0.0, 0.0)
			shaking_time = 0.0
		else:
			shaking_time -= delta
			position = Vector2(	noise.get_noise_1d(global_timer*Constants.SHAKING_NOISE_SCALE), 
								noise.get_noise_1d((global_timer+100.0)*Constants.SHAKING_NOISE_SCALE)) * Constants.SHAKING_OFFSET
		
	
	# Move the blueprint if necessary
	var bp := get_node_or_null("MainScene/Blueprint")
	if bp:
		var mouse_pos := get_global_mouse_position()
		var bg_origin : Vector2 = $MainScene.global_position
		
		var tile_x : int = int((mouse_pos.x - bg_origin.x) / 16)
		var tile_y : int = int((mouse_pos.y - bg_origin.y) / 16)
		bp.position = Vector2(tile_x*16, tile_y*16)
		bp.visible = (tile_x >= 0 and tile_x < Constants.MAP_WIDTH and tile_y >= 0 and tile_y < Constants.MAP_HEIGHT)
		
		# Looking up the obstacle table for an obstacle
		var tile_coord := Vector2i(tile_x, tile_y)
		bp.tile_coord = tile_coord
		
		var is_valid := is_valid_position(tile_coord)
		if not is_valid or not bp.visible:
			bp.set_blocked()
		else:
			bp.set_free()
			
	# Check the current tutorial after init
	if title_displayer.finished:
		check_tutorials()
		
func spawn_enemy(enemy: PackedScene, spawner: Spawn) -> void:
	var new_enemy : Enemy  = enemy.instantiate()
	new_enemy.connect('monster_passed', monster_passed)
	new_enemy.connect('monster_died', monster_died)
	new_enemy.connect('new_monster', new_monster)
	new_enemy.connect('shake', shake)
	new_enemy.connect('summon_enemy', spawn_enemy_at_point)
	new_enemy.connect('play_sound', play_sound)
	if new_enemy.can_scream:
		new_enemy.connect('spawn_scream', spawn_scream)
	if new_enemy.is_boss:
		new_enemy.connect('kill_all', kill_all)
	enemy_list.add_child(new_enemy)
	new_enemy.position = spawner.position
	new_enemy.init(trajectory)
	
	play_sound(Constants.GameSoundId.EnemySpawn)
	
func spawn_enemy_at_point(enemy: PackedScene, spawn_position: Vector2, current_target: int) -> void:
	var new_enemy : Enemy = enemy.instantiate() as Enemy
	new_enemy.connect('monster_passed', monster_passed)
	new_enemy.connect('monster_died', monster_died)
	new_enemy.connect('new_monster', new_monster)
	new_enemy.connect('shake', shake)
	if new_enemy.can_scream:
		new_enemy.connect('spawn_scream', spawn_scream)
	if new_enemy.is_boss:
		new_enemy.connect('kill_all', kill_all)
	enemy_list.add_child(new_enemy)
	new_enemy.init(trajectory)
	new_enemy.position = spawn_position
	new_enemy.current_target = current_target
	
	play_sound(Constants.GameSoundId.EnemySpawn)
	
func unselect_buttons() -> void:
	if arc_twr_btn:
		arc_twr_btn.button_pressed = false
	if mag_twr_btn:
		mag_twr_btn.button_pressed = false
	if drd_twr_btn:
		drd_twr_btn.button_pressed = false
	if can_twr_btn:
		can_twr_btn.button_pressed = false
	
	# Destroying blueprint
	var bp := get_node_or_null("MainScene/Blueprint")
	if bp:
		bp.queue_free()
	
func _input(event: InputEvent) -> void:
	# Unselect
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			unselect_buttons()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not get_tree().paused:
			var bp := get_node_or_null('MainScene/Blueprint')
			if bp:
				if not bp.blocked:
					place_tower()
	# Keys, pause etc.
	elif event is InputEventKey:
		if event.is_action_released('pause') and ui_cooldown == 0.0:
			pause_menu.visible = true
			get_tree().paused = true
			
		var ui_lookup := {'archers': arc_twr_btn,
						  'mages':   mag_twr_btn,
						  'druids':  drd_twr_btn,
						  'cannons': can_twr_btn}
					
		for key : String in ui_lookup.keys():
			var btn : TextureButton = ui_lookup[key]
			if event.is_action_pressed('ui_'+key) and btn and btn.visible and not btn.disabled:
				unselect_buttons()
				btn.pressed.emit()
				btn.set_pressed_no_signal(true)
				
		if event.is_action_pressed('ui_call_next_wave') and not call_wave_btn.disabled:
			call_wave_btn.pressed.emit()
			
		if debug_level:
			if event.is_action_released('dbg_lives'):
				lives += 1
				lives_label.text = str(lives)
			elif event.is_action_released('dbg_money'):
				change_gold(100)
			elif event.is_action_released('dbg_wave'):
				change_gold(spawn.debug_next_wave())
			elif event.is_action_released('dbg_win'):
				level_won()
			elif event.is_action_released('dbg_kill_all'):
				kill_all()
			elif event.is_action_released('dbg_damage'):
				if enemy_list.get_child_count() > 0:
					enemy_list.get_child(0).damage(100000)
				
			if event.is_action_released('speed_up'):
				Engine.time_scale = min(max_speed, Engine.time_scale * speed_accel)
				#dbg_speed_label.text = 'Speed modifier %.2f' % [Engine.time_scale]
			elif event.is_action_released('speed_down'):
				Engine.time_scale = max(min_speed, Engine.time_scale * speed_decel)
				#dbg_speed_label.text = 'Speed modifier %.2f' % [Engine.time_scale]
			
func is_valid_position(pos: Vector2i) -> bool:
	var free := (obstacles.get_cell_tile_data(0, pos) == null)
	var tower := (pos in tower_positions)
	return free and not tower
	
func place_tower() -> void:
	var bp := get_node_or_null("MainScene/Blueprint") as Blueprint
	if not bp: # This should NOT happpen
		return
	
	var instance : Node2D = bp.create_tower_instance()
	towers.add_child(instance)
	instance.connect('play_sound', play_sound)
	tower_positions[bp.tile_coord] = true
	instance.position = bp.tile_coord * 16.0
	change_gold(-instance.cost)
	play_sound(Constants.GameSoundId.Placement)
	
func monster_passed(monster: Enemy) -> void:
	if monster.is_boss:
		%GigaExplosionTimer.start()
		shake(100.0)
	else:
		lives -= 1
	lives_label.text = str(lives)
	
	# BOOO ! You died !
	if lives == 0:  
		get_tree().paused = true
		game_over()
	
func monster_died(monster: Enemy) -> void:
	# WOOP WOOP ! You won !
	if monster.is_boss:
		get_tree().paused = true
		level_won()
	else:
		change_gold(monster.bounty)
	
func shake(time: float) -> void:
	shaking_time += time
	
func game_over() -> void:
	var game_over_screen := GameOver.instantiate()
	game_over_screen.connect('start_over', start_over)
	%LevelMusic.stop()
	$CanvasLayer.add_child(game_over_screen)
	
func start_over() -> void:
	get_tree().reload_current_scene()
	
func level_won() -> void:
	match cur_level:
		1: Progress.level_1_finished = true
		2: Progress.level_2_finished = true
		3: Progress.level_3_finished = true
	Progress.save_progress()
	var tween := get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(victory_panel, 'position:y', 160, 1.0)
	
func check_buttons_availability() -> void:
	# Checking if the button was pressed and remove the blueprint in case of button being disabled
	var check_twr := func(btn: TextureButton, price: int) -> void:
		var bp := get_node_or_null("MainScene/Blueprint")
		if gold < price:
			if btn.button_pressed:
				if bp:
					bp.queue_free()
				btn.set_pressed_no_signal(false)
			btn.disabled = true
		else:
			btn.disabled = not title_displayer.finished
	
	if arc_twr_btn:
		check_twr.call(arc_twr_btn, Constants.TOWER_PRICE_ARCHER)
	if mag_twr_btn:
		check_twr.call(mag_twr_btn, Constants.TOWER_PRICE_MAGE)
	if drd_twr_btn:
		check_twr.call(drd_twr_btn, Constants.TOWER_PRICE_DRUID)
	if can_twr_btn:
		check_twr.call(can_twr_btn, Constants.TOWER_PRICE_CANNON)
	
func change_gold(delta: int) -> void:
	gold += delta
	gold = max(gold, 0)
	gold_label.text = str(gold)
	
func play_sound(sound_id : Constants.GameSoundId) -> void:
	sound_manager.queue_sound(sound_id)
	
func new_monster(monster_name: String, icon: Texture2D) -> void:
	var notif := Notification.instantiate()
	notif.make_monster_notif(monster_name, icon)
	notif_box.add_child(notif)
	check_tutorials(monster_name)
	
func spawn_scream(scream_id: int) -> void:
	# Wave type :
	var en_type  : String = ''
	var delay    : float
	var count    : int
	if cur_level == 2:
		match scream_id:
			0:
				en_type = 'orc'
				delay = 0.5
				count = 20
			1: 
				en_type = 'red_demon'
				delay = 0.25
				count = 30
			2: 
				en_type = 'wendigo'
				delay = 1.0
				count = 20
			3:
				en_type = 'red_demon'
				delay = 0.1
				count = 40
			4: 
				en_type = 'wendigo'
				delay = 0.5
				count = 20
			5:
				en_type = 'red_demon'
				delay = 0.075
				count = 100
	elif cur_level == 3:
		match scream_id:
			0:
				en_type = 'orc'
				delay = 0.1
				count = 100
			1: 
				en_type = 'wendigo'
				delay = 0.1
				count = 100
			2: 
				en_type = 'skeleton'
				delay = 0.1
				count = 500
			3:
				en_type = 'ghost_warrior'
				delay = 0.1
				count = 200
			4: 
				en_type = 'red_demon'
				delay = 0.1
				count = 300
			5:
				en_type = 'orc_shaman'
				delay = 0.1
				count = 200
			6:
				en_type = 'necromancer'
				delay = 0.1
				count = 50
			7: 
				en_type = 'necromancer'
				delay = 0.1
				count = 150
	
	if en_type != '':
		spawn.add_wave(en_type, count, delay, true)

func _on_next_level_pressed() -> void:
	var tween := get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(title_displayer, 'visible', true, 0.0)
	tween.tween_property(title_displayer.fade_out_bg, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Constants.TITLE_DISPLAYER_FADE_OUT_DURATION)
	
	tween.tween_callback(change_level)
	tween.tween_callback(queue_free)

func change_level() -> void:
	var next_scene : Node = load(next_level).instantiate()
	get_tree().root.add_child(next_scene)
	queue_free()

func _on_pause_menu_visibility_changed() -> void:
	ui_cooldown = Constants.UI_COOLDOWN

func update_wave_indicator() -> void:
	if spawn.current_wave <=len(spawn.waves) - 1:
		var wave_id : int
		if spawn.state == Spawn.SpawnerState.WAIT_FOR_ENEMY:
			wave_id = spawn.current_wave+1
		else:
			wave_id = spawn.current_wave
		if wave_id >= len(spawn.waves):
			wave_indicator.texture = null
			%NextWaveLabel.visible = false
			%NextWaveIndicator.visible = false
			return
			
		var next_enemy : PackedScene = spawn.waves[wave_id].enemy_type
		var en : Enemy = next_enemy.instantiate() as Enemy
		wave_indicator.texture = en.icon
		en.queue_free()
	else:
		wave_indicator.texture = null
		
func check_tutorials(monster_name: String = '') -> void:
	var left_tutorials := tutorials.get_child_count()
	if left_tutorials == 0 or not Progress.options['tutorials_enabled']:
		return
	var active_tutorial : Tutorial = tutorials.get_child(0)
	if active_tutorial.unique_id in Progress.seen_tutorials:
		active_tutorial.queue_free()
	elif active_tutorial.trigger_type == Tutorial.TriggerType.AUTO:
		active_tutorial.show_tutorial()
		Progress.seen_tutorials[active_tutorial.unique_id] = true
		Progress.save_progress()
	elif monster_name != '' and monster_name == active_tutorial.encounter_name:
		active_tutorial.show_tutorial()
		Progress.seen_tutorials[active_tutorial.unique_id] = true
		Progress.save_progress()

func _on_finish_game() -> void:
	var opacifier := %Opacifier
	opacifier.modulate = Color(1.0, 1.0, 1.0, 0.0)
	opacifier.visible = true
	var tween := get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(opacifier, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Constants.GAME_WON_FADE_OUT_DURATION)
	tween.tween_callback(start_end_game)
	
func start_end_game() -> void:
	var next_scene : Node = load('res://scenes/end_game.tscn').instantiate()
	get_tree().root.add_child(next_scene)
	queue_free()

func giga_explosion() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var x := rng.randf_range(50.0, 430.0)
	var y := rng.randf_range(50.0, 542.0)
	
	var pos := Vector2(x, y)
	
	var new_explosion := Explosion.instantiate()
	new_explosion.global_position = pos
	add_child(new_explosion)
	play_sound(Constants.GameSoundId.Cannon)
	
	giga_explosions_left -= 1
	if giga_explosions_left == 0:
		get_tree().paused = true
		game_over()
		
func kill_all() -> void:
	for enemy: Enemy in enemy_list.get_children():
		if not enemy.is_boss:
			enemy.damage(10000000)
	spawn.boss_is_dead()


func _on_options_window_visibility_changed() -> void:
	pass 
	
func select_tower(tower_id: int) -> void:
	play_sound(Constants.GameSoundId.Click)
	# Trying to get existing bluepprint
	var bp := get_node_or_null("MainScene/Blueprint")
	if not bp:
		# We create it
		bp = blueprint.instantiate()
		main_scene.add_child(bp)
	bp.select_type(tower_id)
