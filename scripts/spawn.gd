extends Node2D
class_name Spawn

signal spawn_enemy
signal wave_progress
signal wait_progress
signal wait_for_end

enum SpawnerState {
	WAIT_FOR_INIT,
	WAIT_FOR_WAVE,
	WAIT_FOR_ENEMY,
	WAIT_FOR_END
} 

# Waves description are stored in a file where each line is a wave
@export_file("*.txt") var wave_description: String

# Enemies and enemy dict
const goblin        := preload('res://scenes/enemies/goblin.tscn')
const orc           := preload('res://scenes/enemies/orc.tscn')
const orc_shaman    := preload('res://scenes/enemies/orc_shaman.tscn')
const green_dragon  := preload('res://scenes/enemies/green_dragon.tscn')
const red_demon     := preload('res://scenes/enemies/red_demon.tscn')
const minotaur      := preload('res://scenes/enemies/minotaur.tscn')
const wendigo       := preload('res://scenes/enemies/wendigo.tscn')
const red_dragon    := preload('res://scenes/enemies/red_dragon.tscn')
const skeleton      := preload('res://scenes/enemies/skeleton.tscn')
const ghost_warrior := preload('res://scenes/enemies/ghost_warrior.tscn')
const necromancer   := preload('res://scenes/enemies/necromancer.tscn')
const black_dragon  := preload('res://scenes/enemies/black_dragon.tscn')

var enemy_dict := {
	'goblin'        : goblin,
	'orc'           : orc,
	'orc_shaman'    : orc_shaman,
	'green_dragon'  : green_dragon,
	'red_demon'     : red_demon, 
	'minotaur'      : minotaur,
	'wendigo'       : wendigo,
	'red_dragon'    : red_dragon,
	'skeleton'      : skeleton,
	'necromancer'   : necromancer,
	'ghost_warrior' : ghost_warrior,
	'black_dragon'  : black_dragon
}

# A wave associated to the portal
class WaveElement:
	var enemy_type : PackedScene
	var enemy_name : String
	var count : int
	var time_between_enemies : float
	var time_before_next_wave : float
	
	func from_text(line: String, enemy_dict: Dictionary) -> void:
		var tokens := line.split(' ')
		enemy_name = tokens[0]
		count = int(tokens[1])
		time_between_enemies = float(tokens[2])
		time_before_next_wave = float(tokens[3])
		enemy_type = enemy_dict[enemy_name]

# Local variables
var current_wave : int
var current_enemy : PackedScene
var enemies_left : int
var state : SpawnerState

var time_left        : float
var time_tot         : float
var enemy_spawn_time : float

var waves : Array[WaveElement] = [] 

var active := true
var closed := true

var level_name := ''

@onready var dbg_current_wave  := %CurrentWave
@onready var dbg_current_enemy := %CurrentEnemy
@onready var dbg_enemies_left  := %EnemiesLeft

func _ready() -> void:
	$AnimatedSprite2D.play('closed')
	load_waves_from_file()
	
	current_wave = 0
	load_wave()
	
	active = true
	
func activate() -> void:
	active = true # meh ...
	
func load_waves_from_file() -> void:
	# Use this to load the file : https://docs.godotengine.org/en/stable/classes/class_fileaccess.html
	var file := FileAccess.open(wave_description, FileAccess.READ)
	
	# First line has a text : The level name
	level_name = file.get_line()
	
	# Second line has a float (time before the portal opens)
	time_tot = float(file.get_line())
	time_left = time_tot
	state = SpawnerState.WAIT_FOR_INIT
	
	# Then we read 
	while not file.eof_reached():
		var line := file.get_line()
		if line.strip_edges() == '':
			break
		var element := WaveElement.new()
		element.from_text(line, enemy_dict)
		waves.append(element)

func _process(delta: float) -> void:
	if not active:
		return
	
	process_spawns(delta)
	
	dbg_enemies_left.text  = 'Enemies left: %d' % [enemies_left]
	dbg_current_wave.text  = 'Current Wave: %d' % [current_wave]
	var en_name : String
	if current_wave < len(waves):
		en_name = waves[current_wave].enemy_name
	else:
		en_name = 'No more enemies'
	dbg_current_enemy.text = 'Current Enemy: %s' % [en_name]
	
func process_spawns(delta: float) -> void:
	var sig : String
	# If we have not started yet, we wait for the portal to open
	time_left = max(time_left - delta, 0.0)
	enemy_spawn_time = max(enemy_spawn_time - delta, 0.0)
	
	if state == SpawnerState.WAIT_FOR_INIT:
		if time_left == 0.0:
			closed = false
			$AnimatedSprite2D.play('open')
			print('Init is over, starting wave')
			next_wave()
		sig = 'wait_progress'
	elif state == SpawnerState.WAIT_FOR_ENEMY:
		if enemy_spawn_time == 0.0:
			enemies_left -= 1
			emit_signal('spawn_enemy', current_enemy, self)
			
			if enemies_left == 0:
				print('No more enemies, going to the next wave')
				next_wave()
				if state != SpawnerState.WAIT_FOR_END:
					sig = 'wait_progress'
			else:
				enemy_spawn_time = waves[current_wave].time_between_enemies
				sig = 'wave_progress'
		else:
			sig = 'wave_progress'
	elif state == SpawnerState.WAIT_FOR_WAVE:
		if time_left == 0.0:
			state = SpawnerState.WAIT_FOR_ENEMY
			sig = 'wave_progress'
			print('Waiting is over, starting wave with %d enemies' % [waves[current_wave].count])
			enemy_spawn_time = 0.0
			time_tot = waves[current_wave].time_between_enemies * (waves[current_wave].count-1)
			time_left = time_tot
		else:
			sig = 'wait_progress'
	if sig != '':
		emit_signal(sig, time_left, time_tot)
				  
# Starts the next wave
func next_wave() -> void:
	# Could init current_wave to -1 but it would be ugly
	if state != SpawnerState.WAIT_FOR_INIT:
		current_wave += 1   
	
	if current_wave >= len(waves):
		closed = true
		$AnimatedSprite2D.play('closed')
		state = SpawnerState.WAIT_FOR_END
		emit_signal('wait_for_end')
	else:
		time_tot = waves[current_wave-1].time_before_next_wave
		time_left = time_tot
		if state == SpawnerState.WAIT_FOR_INIT: # Fix to make sure we don't wait additional time for the first wave
			time_left = 0
		state = SpawnerState.WAIT_FOR_WAVE
		load_wave()
		
func load_wave() -> void:
	var wave := waves[current_wave]
	enemies_left = wave.count
	current_enemy = wave.enemy_type  
	
func add_wave(enemy: String, count: int, delay: float, start_now: bool) -> void:
	var wave := WaveElement.new()
	wave.from_text('%s %d %f 0' % [enemy, count, delay], enemy_dict)
	waves.append(wave)
	if start_now and state == SpawnerState.WAIT_FOR_END:
		load_wave()
		state = SpawnerState.WAIT_FOR_ENEMY
		time_tot = waves[current_wave].time_between_enemies * (waves[current_wave].count-1)
		time_left = time_tot
		_on_skip_waiting()
		
func _on_skip_waiting() -> void:
	if state != SpawnerState.WAIT_FOR_INIT && state != SpawnerState.WAIT_FOR_WAVE:
		return
		
	if state == SpawnerState.WAIT_FOR_INIT:
		$AnimatedSprite2D.play('open')
	if current_wave < len(waves):
		state = SpawnerState.WAIT_FOR_ENEMY
		enemy_spawn_time = 0.0
	time_tot = waves[current_wave].time_between_enemies * (waves[current_wave].count-1)
	time_left = time_tot
	
func debug_next_wave() -> int:
	var en := current_enemy.instantiate()
	var gold : int = enemies_left * en.bounty
	en.queue_free()
	
	if state == SpawnerState.WAIT_FOR_INIT:
		state = SpawnerState.WAIT_FOR_WAVE
	next_wave()
	return gold
	
func boss_is_dead() -> void:
	current_wave = 10000
	state = SpawnerState.WAIT_FOR_END
	enemies_left = 0
	
