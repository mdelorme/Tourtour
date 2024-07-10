extends Node

const SAVE_FILE := "user://savegame.save"

var game_just_started := true

var level_1_started := true
var level_2_started := false
var level_3_started := false

var level_1_finished := false
var level_2_finished := false
var level_3_finished := false

var goblin_encountered        := false
var orc_encountered           := false
var orc_shaman_encountered    := false
var green_dragon_encountered  := false
var red_demon_encountered     := false
var minotaur_encountered      := false
var wendigo_encountered       := false
var red_dragon_encountered    := false
var skeleton_encountered      := false
var necromancer_encountered   := false
var ghost_warrior_encountered := false
var black_dragon_encountered  := false 

var seen_tutorials := {}
var options := {}

var codex_ref_table := {
	'goblin':          goblin_encountered,
	'orc':             orc_encountered,
	'orc_shaman':      orc_shaman_encountered,
	'green_dragon':    green_dragon_encountered,
	'red_demon':       red_demon_encountered,
	'minotaur':        minotaur_encountered,
	'wendigo':         wendigo_encountered,
	'red_dragon':      red_dragon_encountered,
	'skeleton':        skeleton_encountered,
	'necromancer':     necromancer_encountered,
	'ghost_warrior':   ghost_warrior_encountered,
	'black_dragon':    black_dragon_encountered,
	'level1':          level_1_started,
	'level2':          level_2_started,
	'level3':          level_3_started,
	'level1_finished': level_1_finished,
	'level2_finished': level_2_finished,
	'level3_finished': level_3_finished
}

func rebuild_codex_ref() -> void:
	codex_ref_table = {
		'goblin':          goblin_encountered,
		'orc':             orc_encountered,
		'orc_shaman':      orc_shaman_encountered,
		'green_dragon':    green_dragon_encountered,
		'red_demon':       red_demon_encountered,
		'minotaur':        minotaur_encountered,
		'wendigo':         wendigo_encountered,
		'red_dragon':      red_dragon_encountered,
		'skeleton':        skeleton_encountered,
		'necromancer':     necromancer_encountered,
		'ghost_warrior':   ghost_warrior_encountered,
		'black_dragon':    black_dragon_encountered,
		'level1':          level_1_started,
		'level2':          level_2_started,
		'level3':          level_3_started,
		'level1_finished': level_1_finished,
		'level2_finished': level_2_finished,
		'level3_finished': level_3_finished
	}

func save_progress() -> void:
	var save_game := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	rebuild_codex_ref()
	var json_string := JSON.stringify(codex_ref_table)
	save_game.store_line(json_string)
	json_string = JSON.stringify(seen_tutorials)
	save_game.store_line(json_string)
	json_string = JSON.stringify(options)
	save_game.store_line(json_string)
		
func load() -> void:
	#return # For now empty codex every time
	if not FileAccess.file_exists(SAVE_FILE):
		default_values()
	var save_game := FileAccess.open(SAVE_FILE, FileAccess.READ)
	
	# Reading json for the codex
	var json : Dictionary = JSON.parse_string(save_game.get_line())
	
	goblin_encountered        = json['goblin']
	orc_encountered           = json['orc']
	orc_shaman_encountered    = json['orc_shaman']
	green_dragon_encountered  = json['green_dragon']
	red_demon_encountered     = json['red_demon']
	minotaur_encountered      = json['minotaur']
	wendigo_encountered       = json['wendigo']
	red_dragon_encountered    = json['red_dragon']
	skeleton_encountered      = json['skeleton']
	necromancer_encountered   = json['necromancer']
	ghost_warrior_encountered = json['ghost_warrior']
	black_dragon_encountered  = json['black_dragon']
	level_1_started           = json['level1']
	level_2_started           = json['level2']
	level_3_started           = json['level3']
	level_1_finished          = json['level1_finished']
	level_2_finished          = json['level2_finished']
	level_3_finished          = json['level3_finished']
	
	rebuild_codex_ref() 
	
	# Reading json for tutorial progress
	var line := save_game.get_line()
	if line:
		seen_tutorials = JSON.parse_string(line)
	
	# Reading options 
	line = save_game.get_line()
	if line:
		options = JSON.parse_string(line)
		
		set_audio_bus_volume('Master', options['master_volume'])
		set_audio_bus_volume('Effects', options['effects_volume'])
		set_audio_bus_volume('Music', options['music_volume'])
		set_audio_bus_volume('Environment', options['env_volume'])
		
	else:
		default_values()
		
	set_screen_mode(options['screen_mode'])
		
func default_values() -> void:
	options['master_volume']     = 0.0
	options['music_volume']      = 0.0
	options['effects_volume']    = 0.0
	options['env_volume']        = 0.0
	options['screen_mode']       = 'Fullscreen'
	options['tutorials_enabled'] = true
	
	save_progress()
	
func reset() -> void:
	goblin_encountered        = false
	orc_encountered           = false
	orc_shaman_encountered    = false
	green_dragon_encountered  = false
	red_demon_encountered     = false
	minotaur_encountered      = false
	wendigo_encountered       = false
	red_dragon_encountered    = false
	skeleton_encountered      = false
	necromancer_encountered   = false
	ghost_warrior_encountered = false
	black_dragon_encountered  = false
	level_1_started           = false
	level_2_started           = false
	level_3_started           = false
	level_1_finished          = false
	level_2_finished          = false
	level_3_finished          = false
	
	save_progress()

# This method should clearly be somewhere else. 
# Next time, I willimplement a Singleton to manage the sound of the 
# game and will avoid having left over methods like this one ...
func set_audio_bus_volume(bus_name: String, value: float) -> void:
	var bus_id := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_id, value)
	AudioServer.set_bus_mute(bus_id, value == -70)
	
# Same for you ... But even worse because everything is hardcoded ... 
# But eh, it works !
func set_screen_mode(screen_mode: int) -> void:
	print('Setting screen mode to ', screen_mode)
	var new_window_mode : DisplayServer.WindowMode = DisplayServer.window_get_mode()
	match screen_mode:
		0: new_window_mode = DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
		1: new_window_mode = DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED
		2: new_window_mode = DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
		
	DisplayServer.window_set_mode(new_window_mode)
