extends Node2D
class_name Enemy

signal monster_passed(monster: Enemy)                               # The monster reached the end line !
signal monster_died(monster : Enemy)                                # The monster got killed
signal new_monster(monster_name : String, icon : Texture2D)         # The monster has never been seen before
signal spawn_scream                                                 # Spawns a wave of monsters
signal shake(time : float)                                          # Shake the screen
signal summon_enemy(enemy : Enemy, position : Vector2, target: int) # Summons an enemy from a necromancer
signal play_sound(sound: Constants.GameSoundId)
signal kill_all                                                     # Used when a boss dies to clear the screen

# Possible summons
const skeleton      := preload('res://scenes/enemies/skeleton.tscn')
const ghost_warrior := preload('res://scenes/enemies/ghost_warrior.tscn')

@export var icon : Texture2D
@export var monster_name : String
@export var life : int
@export var speed : float
@export var frames : SpriteFrames
@export var is_boss : bool
@export var bounty : int # How much money the player wins if they kills the monster
@export var can_be_frozen : bool = true
@export var can_be_electrocuted : bool = true
@export var can_scream : bool = false
@export var can_burrow : bool = false
@export var immune_to_cannon : bool = false
@export var immune_to_arrows : bool = false
@export var can_summon : bool = false

@export var dying_sound : Constants.GameSoundId = Constants.GameSoundId.GoblinDeath

const Explosion := preload('res://scenes/explosion2.tscn')

var line : Line2D
var current_target : int
var active := true
var max_life : int
var slowdown : float
var slowdown_cooldown : float
var is_electrified : bool
var damageable : bool

var boss_dying : bool = false
var center_pos : Vector2 # for boss death
var cooldown_before_death : float
var next_explosion: float

var scream_cooldown : float
var is_screaming : bool
var scream_id : int

var burrow_exit : Vector2
var burrow_exit_line_point : int

var summoning_cooldown : float
var summoning_left : int
var summoning_counter : int

var glow_time : float
var advancement : float

enum State {
	EST_WALKING,
	EST_SCREAMING,
	EST_INVOKING,
	EST_BURROW_IN,
	EST_BURROW_OUT,
	EST_SUMMONING
}
var state : State

func _ready() -> void:
	$AnimatedSprite.sprite_frames = frames
	slowdown = 1.0
	slowdown_cooldown = 0.0
	summoning_counter = 0
	is_electrified = false
	
	glow_time = 0.0
	
	damageable = true
	state = State.EST_WALKING
	
	if can_scream:
		scream_cooldown = Constants.BOSS_SCREAM_COOLDOWN
		scream_id = 0
	if is_boss:
		emit_signal('play_sound', Constants.GameSoundId.DragonScream)
	if can_summon:
		summoning_cooldown = Constants.NECRO_SUMMON_COOLDOWN
		summoning_left     = Constants.NECRO_SUMMON_NUMBER
	
	check_progress()
	
	advancement = 0
	
func init(new_line : Line2D) -> void:
	line = new_line
	current_target = 1 
	max_life = life
	if len(line.points) > 0:
		position = line.get_point_position(0) + line.position
		
	if is_boss:
		emit_signal('shake', Constants.SHAKING_TIME_BOSS)
	
func get_advancement() -> float:
	return advancement
	
func compute_advancement() -> float:
	var total_length := 0.0
	for i in range(current_target-1):
		var p1 := line.get_point_position(i)
		var p2 := line.get_point_position(i+1)
		
		total_length += p1.distance_to(p2)
		
	var p := line.get_point_position(current_target-1) + line.position
	total_length += p.distance_to(position)
	return total_length

func _physics_process(delta: float) -> void:
		
	if not active:
		return
		
	if not line:
		print('Error no target defined for monster')
		
	if can_scream:
		scream_cooldown = max(scream_cooldown - delta, 0.0)
		if scream_cooldown == 0.0:
			match state:
				State.EST_WALKING:   toggle_scream()
				State.EST_SCREAMING: toggle_scream()
				
	if can_summon:
		summoning_cooldown = max(summoning_cooldown - delta, 0.0)
		if summoning_cooldown == 0.0:
			match state:
				State.EST_WALKING:   toggle_summon()
				State.EST_SUMMONING: toggle_summon()
		
	if slowdown_cooldown > 0.0:
		slowdown_cooldown = max(0.0, slowdown_cooldown - delta)
		modulate = Color(Constants.COLOR_SLOWDOWN)
	else:
		slowdown = 1.0
		modulate = Color(1.0, 1.0, 1.0, 1.0)    
		
	# Otherwise, we check our position wrt the point
	if state == State.EST_WALKING:
		if not line:
			return
			
		if len(line.points) > 0:
			var next_point := line.get_point_position(current_target) + line.position
			
			# We test the next position
			var dx := 0.0 # Direction along x
			var dy := 0.0 # Direction along y
			var anim := ''
			if next_point.x > position.x:
				dx = 1.0
				dy = 0.0
				anim = 'walk_right'
			elif next_point.x < position.x:
				dx = -1.0
				dy = 0.0
				anim = 'walk_left'
			elif next_point.y > position.y:
				dx = 0.0
				dy = 1.0
				anim = 'walk_down' 
			else:
				dx = 0.0
				dy = -1.0
				anim = 'walk_up'
				
			if $AnimatedSprite.animation != anim:
				$AnimatedSprite.play(anim)
			
			var dist := next_point.distance_to(position)
			var increment := speed*slowdown*delta
			if dist < increment:
				position = next_point
				current_target += 1
				if current_target >= line.get_point_count():
					if not is_boss:
						$AnimatedSprite.play('die')
					else:
						emit_signal('monster_passed', self)
					emit_signal('shake', Constants.SHAKING_TIME)
					active = false
			else:
				position += Vector2(dx, dy)*increment
				position += Vector2(0.0, 0.0)
	if $Glow.visible:
		glow_time += delta
		var scale_value := 0.3 + 0.01 * sin(glow_time * 50.0)
		$Glow.scale = Vector2(scale_value, scale_value)
		
	advancement = compute_advancement()
		
		
func damage(amount: int) -> void:
	if not damageable:
		return
		
	life = max(0, life-amount)
	const width := 16.0
	var life_prop : int = int(width * life / max_life)
	var change_pos := life_prop - 8
	$LifeLeft.set_point_position(1, Vector2i(change_pos, -9))
	$LifeLeft.visible = true
	$LifeLost.visible = true
	
	if life == 0:
		$AnimatedSprite.play('die')
		damageable = false
		can_be_frozen = false
		slowdown_cooldown = 0.0
		$Glow.hide()
		modulate = Color(1.0, 1.0, 1.0, 1.0)  
		
		emit_signal('play_sound', dying_sound)
		
		if is_boss:
			emit_signal('kill_all')
		
		if $Area2D:
			$Area2D.queue_free()
		active = false
		$LifeLeft.visible = false
		$LifeLost.visible = false
		
		if is_boss:
			boss_dying = true
			center_pos = position
			%BossDeathTimer.start(Constants.BOSS_DEATH_COOLDOWN)
			$Particles.visible = true
			emit_signal('shake', Constants.BOSS_DEATH_COOLDOWN)
		
func apply_slowdown(amount: float, cooldown: float) -> void:
	if not can_be_frozen:
		return
	slowdown = amount
	slowdown_cooldown = cooldown 
		

func _on_animated_sprite_animation_finished() -> void:
	if $AnimatedSprite.animation == 'die':
		if life == 0:
			emit_signal('monster_died', self)
		else:
			emit_signal('monster_passed', self)
		queue_free()
	elif $AnimatedSprite.animation == 'spin':
		if state == State.EST_BURROW_IN:
			global_position = burrow_exit
			$AnimatedSprite.play('spin')
			state = State.EST_BURROW_OUT
		elif state == State.EST_BURROW_OUT:
			state = State.EST_WALKING
			current_target = burrow_exit_line_point
	elif $AnimatedSprite.animation == 'summon':
		summon()
		summoning_left -= 1
		if summoning_left == 0:
			state = State.EST_WALKING
			summoning_cooldown = Constants.NECRO_SUMMON_COOLDOWN
		else:
			$AnimatedSprite.play('summon')
			emit_signal('play_sound', Constants.GameSoundId.EnemySpawn)
		
func check_progress() -> void:
	# Updates progress if we've never encountered this monster
	var never_seen : bool = false
	match monster_name:
		'MONSTER_GOBLIN':
			if not Progress.goblin_encountered:
				never_seen = true
				Progress.goblin_encountered = true
		'MONSTER_ORC':
			if not Progress.orc_encountered:
				never_seen = true
				Progress.orc_encountered = true
		'MONSTER_ORC_SHAMAN':
			if not Progress.orc_shaman_encountered:
				never_seen = true
				Progress.orc_shaman_encountered = true
		'MONSTER_GREEN_DRAGON':
			if not Progress.green_dragon_encountered:
				never_seen = true
				Progress.green_dragon_encountered = true
		'MONSTER_RED_DEMON':
			if not Progress.red_demon_encountered:
				never_seen = true
				Progress.red_demon_encountered = true
		'MONSTER_MINOTAUR':
			if not Progress.minotaur_encountered:
				never_seen = true
				Progress.minotaur_encountered = true
		'MONSTER_WENDIGO':
			if not Progress.wendigo_encountered:
				never_seen = true
				Progress.wendigo_encountered = true
		'MONSTER_RED_DRAGON':
			if not Progress.red_dragon_encountered:
				never_seen = true
				Progress.red_dragon_encountered = true
		'MONSTER_SKELETON':
			if not Progress.skeleton_encountered:
				never_seen = true
				Progress.skeleton_encountered = true
		'MONSTER_GHOST_WARRIOR':
			if not Progress.ghost_warrior_encountered:
				never_seen = true
				Progress.ghost_warrior_encountered = true
		'MONSTER_NECROMANCER':
			if not Progress.necromancer_encountered:
				never_seen = true
				Progress.necromancer_encountered = true
		'MONSTER_BLACK_DRAGON':
			if not Progress.black_dragon_encountered:
				never_seen = true
				Progress.black_dragon_encountered = true
				
	if never_seen:
		emit_signal('new_monster', monster_name, icon)
		Progress.save_progress()
		
func make_explosion() -> void:
	var pos := Vector2((randf()-0.5) * Constants.BOSS_EXPLOSION_RADIUS,
					   (randf()-0.5) * Constants.BOSS_EXPLOSION_RADIUS)
	var explosion := Explosion.instantiate()
	explosion.position = pos
	add_child(explosion)

func toggle_scream() -> void:
	if state == State.EST_WALKING:
		state = State.EST_SCREAMING
		var anim : String = $AnimatedSprite.animation.replace('walk', 'scream')
		$AnimatedSprite.play(anim)
		scream_cooldown = Constants.BOSS_SCREAM_TIME
		emit_signal('shake', scream_cooldown)
		emit_signal('play_sound', Constants.GameSoundId.DragonScream)
	elif state == State.EST_SCREAMING:
		state = State.EST_WALKING
		var anim : String = $AnimatedSprite.animation.replace('scream', 'walk')
		$AnimatedSprite.play(anim)
		scream_cooldown = Constants.BOSS_SCREAM_COOLDOWN
		emit_signal('spawn_scream', scream_id)
		scream_id += 1
		
func toggle_summon() -> void:
	if state == State.EST_WALKING:
		state = State.EST_SUMMONING
		summoning_left = Constants.NECRO_SUMMON_NUMBER
		$AnimatedSprite.play('summon')
		summoning_counter = 1-summoning_counter # 0 <-> 1
		
func burrow(end_position: Vector2, line_point: int) -> void:
	$AnimatedSprite.play('spin')
	state = State.EST_BURROW_IN
	burrow_exit = end_position
	burrow_exit_line_point = line_point
	
func summon() -> void:
	# Alternate between skeletons and ghost warriors
	if summoning_counter == 0:
		emit_signal('summon_enemy', skeleton, position, current_target)
	else:
		emit_signal('summon_enemy', ghost_warrior, position, current_target)
		
func toggle_electrocute(electrocute: bool) -> void:
	if active:
		$Glow.visible = electrocute

func _on_boss_death() -> void:
	$Particles.visible = false
	$AnimatedSprite.play('walk_down')
	z_index = 15
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, 'global_position', Vector2(240, 312), 3.0)
	tween.tween_property(self, 'scale', Vector2(100, 100), 3.0)
	tween.chain().tween_callback(boss_death)
	
func boss_death() -> void:
	emit_signal('monster_died', self)
	queue_free()
