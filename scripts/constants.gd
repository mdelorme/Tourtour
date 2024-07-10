extends Node

const MAP_WIDTH := 30
const MAP_HEIGHT := 30

const TILE := 16
const HALF_TILE := 8

const START_LIFE := 10
const START_GOLD := 200

const SHAKING_TIME      := 0.05
const SHAKING_TIME_BOSS := 2.0
const SHAKING_OFFSET    := 7.0
const SHAKING_NOISE_SCALE := 1000.0

const UI_COOLDOWN := 0.1

# Could be done with an enum I guess
enum TowerType {
	Archer,
	Mage,
	Druid,
	Cannon
}

# Archer tower constants
const TOWER_PRICE_ARCHER     := 100
const TOWER_FIRE_RATE_ARCHER := 0.2
const TOWER_RANGE_ARCHER     := 90.0
const TOWER_DAMAGE_ARCHER    := 90
const TOWER_COLOR_ARCHER     := Color('ceeac8', 0.50)
const TOWER_COLOR_RIM_ARCHER := Color('60bc4d', 0.80)

# Mage tower constants
const TOWER_PRICE_MAGE     := 75
const TOWER_FIRE_RATE_MAGE := 1.0
const TOWER_RANGE_MAGE     := 60.0
const TOWER_DAMAGE_MAGE    := 70
const TOWER_SLOWDOWN_MAGE  := 0.7
const TOWER_COLOR_MAGE     := Color('d7e4f4', 0.50)
const TOWER_COLOR_RIM_MAGE := Color('4d7ebc', 0.80)

# Druid tower constants
const TOWER_PRICE_DRUID      := 150
const TOWER_FIRE_RATE_DRUID  := 0.1
const TOWER_RANGE_DRUID      := 2000.0
const TOWER_DAMAGE_DRUID     := 5
const TOWER_COLOR_DRUID      := Color('c2b7eb', 0.50)
const TOWER_COLOR_RIM_DRUID  := Color('7861d3', 0.80)

# Cannon tower constants
const TOWER_PRICE_CANNON     := 300 #150
const TOWER_FIRE_RATE_CANNON := 4.0
const TOWER_RANGE_CANNON     := 100.0
const TOWER_DAMAGE_CANNON    := 300
const TOWER_AOE_CANNON       := 100.0
const TOWER_COLOR_CANNON     := Color('f5d0d4', 0.50)
const TOWER_COLOR_RIM_CANNON := Color('c15b61', 0.80)

# Number of points to draw on tower range
const DRAW_CIRCLE_NPTS := 32

# Game Sounds
enum GameSoundId {
	# UI
	Click,
	Placement,
	
	# Enemies
	EnemySpawn,
	GoblinDeath,
	OrcDeath,
	WendigoDeath,
	RedDemonDeath,
	MinotaurDeath,
	SkeletonDeath,
	NecromancerDeath,
	GhostWarriorDeath,
	DragonScream,
	DragonDepossession,
	
	# Projectiles
	Arrow,
	Mages,
	Cannon,
	Druids
	
}

# Main menu
const FONT_COLOR_SELECTED     := Color('#ecba00')
const FONT_COLOR_UNSELECTED   := Color('#ffffff')
const FONT_OUTLINE_SELECTED   := 10
const FONT_OUTLINE_UNSELECTED := 0
const MENU_TRANSITION_DURATION := 0.1


# Slowdown
const COLOR_SLOWDOWN         := Color(0.61, 0.79, 1.00, 1.00)
const SLOWDOWN_COOLDOWN      := 2.0
const SLOWDOWN_RADIUS        := 50.0
const ICE_EXPLOSION_COOLDOWN := 0.5
const COLOR_ICE_EXPLOSION    := Color(0.81, 1.00, 0.91, 0.20)


# Notifications
const NOTIFICATION_COOLDOWN := 5.0
const NOTIFICATION_GROWTH_DURATION := 0.1
const NOTIFICATION_SHOWING_DURATION := 0.5

# Level displayer
const TITLE_DISPLAYER_INIT_WAIT := 1.0
const TITLE_DISPLAYER_INTER_WAIT := 1.0
const TITLE_DISPLAYER_SLIDE_IN_DURATION := 0.3
const TITLE_DISPLAYER_WAIT_TIME := 1.5
const TITLE_DISPLAYER_FADE_OUT_DURATION := 0.5

# Game over
const GAMEOVER_INIT_SPEED := 0.5
const GAMEOVER_TXT_SPEED := 1.0
const GAMEOVER_TXT2_SPEED := 0.5

# Boss 
const BOSS_DEATH_COOLDOWN := 3.0
const BOSS_DEATH_EXPLOSION_COOLDOWN := 0.1
const BOSS_EXPLOSION_RADIUS := 30.0
const BOSS_SCREAM_COOLDOWN := 13.0
const BOSS_SCREAM_TIME := 3.0

# Necromancer
const NECRO_SUMMON_COOLDOWN := 3.0
const NECRO_SUMMON_NUMBER   := 4

# Game finished
const GAME_WON_FADE_OUT_DURATION := 2.0

# Giga explosion
const GIGA_EXPLOSION_COUNT := 400
const GIGA_EXPLOSION_SEPARATION := 0.5
