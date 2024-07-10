extends Node

# Preloading all the sounds when loading the script
var click               := preload("res://assets/sounds/ui/click_138.wav")
var placement           := preload("res://assets/sounds/ui/placement.wav")
var arrow               := preload("res://assets/sounds/towers/arrow.wav")
var mages               := preload("res://assets/sounds/towers/mage.wav")
var druids              := preload("res://assets/sounds/towers/mage.wav")
var cannons             := preload("res://assets/sounds/towers/cannon.wav")
var spawn               := preload("res://assets/sounds/enemies/spawning.wav")
var goblin_death        := preload("res://assets/sounds/enemies/goblin_dying.wav")
var orc_death           := preload("res://assets/sounds/enemies/orc_dying.wav")
var wendigo_death       := preload("res://assets/sounds/enemies/wendigo_dying.wav")
var minotaur_death      := preload("res://assets/sounds/enemies/minotaur_dying.wav")
var red_demon_death     := preload("res://assets/sounds/enemies/red_demon_dying.wav")
var skeleton_death      := preload("res://assets/sounds/enemies/skeleton_dying.wav")
var ghost_warrior_death := preload("res://assets/sounds/enemies/ghost_warrior_dying.wav")
var necromancer_death   := preload("res://assets/sounds/enemies/necromancer_dying.wav")
var dragon_depossession := preload("res://assets/sounds/enemies/dragon_depossession.wav")
var dragon_scream       := preload("res://assets/sounds/enemies/dragon_scream.wav")

# Pool of sound objects
var pool : Dictionary
const pool_max_size := 20

@export var sound_bank : Dictionary

func _ready() -> void:
	# UI entries
	sound_bank[Constants.GameSoundId.Click] = [click, "UI"]
	sound_bank[Constants.GameSoundId.Placement] = [placement, "UI"]
	
	# Towers
	sound_bank[Constants.GameSoundId.Arrow]   = [arrow, "Archers"]
	sound_bank[Constants.GameSoundId.Mages]   = [mages, "Mages"]
	sound_bank[Constants.GameSoundId.Druids]  = [druids, "Druids"]
	sound_bank[Constants.GameSoundId.Cannon]  = [cannons, "Cannons"]
	
	# Monsters
	sound_bank[Constants.GameSoundId.EnemySpawn]         = [spawn, "Monsters"]
	sound_bank[Constants.GameSoundId.GoblinDeath]        = [goblin_death, "Monsters"]
	sound_bank[Constants.GameSoundId.OrcDeath]           = [orc_death, "Monsters"]
	sound_bank[Constants.GameSoundId.WendigoDeath]       = [wendigo_death, "Monsters"]
	sound_bank[Constants.GameSoundId.MinotaurDeath]      = [minotaur_death, "Monsters"]
	sound_bank[Constants.GameSoundId.RedDemonDeath]      = [red_demon_death, "Monsters"]
	sound_bank[Constants.GameSoundId.SkeletonDeath]      = [skeleton_death, "Monsters"]
	sound_bank[Constants.GameSoundId.GhostWarriorDeath]  = [ghost_warrior_death, "Monsters"]
	sound_bank[Constants.GameSoundId.NecromancerDeath]   = [necromancer_death, "Monsters"]
	sound_bank[Constants.GameSoundId.DragonDepossession] = [dragon_depossession, "Monsters"]
	sound_bank[Constants.GameSoundId.DragonScream]       = [dragon_scream, "Monsters"]
	
func _process(_delta: float) -> void:
	for sound: Constants.GameSoundId in pool:
		var stream : AudioStreamPlayer = pool[sound]
		add_child(stream)
		stream.play()
	pool = {}

func queue_sound(sound_id : Constants.GameSoundId) -> void:
	if sound_id not in sound_bank:
		print('Warning : Missing sound file for ', sound_id)
		return
		
	# No need to queue if already present
	if sound_id in pool:
		return
	
	# No space left in pool
	if len(pool) >= pool_max_size:
		return
		
	# Creating the stream and adding it to the pool
	var audio_stream := AudioStreamPlayer.new()
	audio_stream.connect('finished', audio_stream.queue_free)
	
	var stream : AudioStream = sound_bank[sound_id][0]
	var bus    : String = sound_bank[sound_id][1]
	
	audio_stream.stream = stream
	audio_stream.bus = bus
	pool[sound_id] = audio_stream
