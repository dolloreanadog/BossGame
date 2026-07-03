extends Resource
## Base Weapon Class which all weapons inherit from
class_name Weapon

# INFO: We might want to modulize the gun a bit, for example seperate the fire1 & fire2 to seperate scripts

## What kind of weapon it is
enum WeaponType {
	AR, ## An Assault Rifle
	PISTOL, ## decent secondary
	SNIPER, ## Long Range power gun
	MG, ## Powerful cumbersone sustain gun
	SMG, ## An Semi Automatic Gun
	SHOTGUN, ## Short range big damage
	}
# AR, PISTOL, SNIPER, MG, SMG
# TODO: We're following this https://www.youtube.com/watch?v=SB0QrnI_-IQ

var player: PlayerCharacter

## INFO: These are the default values we change in editor and SHOULD NOT BE EDITED IN GAME
@export var weapon_id: int = 0
@export var weapon_name: String = "Weapon"
@export var type: WeaponType
@export_group("Weapon Effects Scripts")
@export var shoot_script_1: WeaponEffect
@export var shoot_script_2: WeaponEffect
@export var ability_script: WeaponEffect
@export var reload_script: WeaponEffect
## To better view, go to an empty scene, and attach the scene to a weapon slot
@export_group("Visual")
@export var bullet_decal: PackedScene
# TODO: need a weapon tracer
## This is what the world sees besides the player

## This is what the player sees as we'll hide the world mesh


@export_subgroup("World Model")
@export var world_mesh: PackedScene
@export var world_position: Vector3
@export var world_rotation: Vector3
@export_subgroup("View Model")
@export var view_mesh: PackedScene
@export var view_position: Vector3
@export var view_rotation: Vector3
@export_group("Attributes")
## See if the player can fire at all
@export var can_all_fire: bool = true
@export var can_alt_fire: bool = false
@export var _damage: float = 1
@export var _alt_damage: float = 1
## Decide whether it is a click to shoot or hold to shoot
@export_range(0, 100, 0.01) var _accuracy: float = 100:
	set(value):
		_accuracy = clampf(value, 0, 100)
@export_range(0, 100, 0.01) var _alt_accuracy: float = 100:
	set(value):
		_alt_accuracy = clampf(value, 0, 100)
## How many bullets it fires, don't put at 0
@export var pellet_count: int = 1
@export var alt_pellet_count: int = 1
## Only usable when pellet count is above 0
@export var spread_angle: float = 0
@export var manual_fire: bool = false
@export var _fire_rate: float = 0.5
@export var _alt_fire_rate: float = 1
@export var _ammo: int = 10
## How much ammo the secondary uses.
@export var secondary_ammo: int = 1
@export var _recoil: float = 1
@export var _alt_recoil: float = 1
@export var _reload_time: float = 1
@export var move_speed: float = 5
@export var shoot_slow: float = 4.5
## The set speed when they reload
@export var reload_slow: float = 4
@export var _weak_point_mult: float = 1.25
@export var _crit_mult: float = 1.5
@export_range(0, 1) var _crit_chance: float = 0:
	set(value):
		_crit_chance = clampf(value, 0, 1)
@export var _switch_time: float = 1
## Think of the Vector from ZS, we can have it reach to the power to activate something. [br]
## Another thing is to have it so the farther the value is, something happens (like damage increase).
@export var power: float = 0
@export var raycast_range: float = -10
## If the damage can pierce through resistance and shield
@export var is_pure: bool = false
# TODO: sometimes maybe we want to give a debuff to the boss, need a way to implement
# TODO: also we can implement a counter


## INFO: These are the adjustable values we can change in game
var current_damage: float = 1
var current_alt_damage: float = 1
var current_accuracy: float = 1:
	set(value):
		current_accuracy = clampf(value, 0, 100)
var current_alt_accuracy: float = 1:
	set(value):
		current_alt_accuracy = clampf(value, 0, 100)
var current_fire_rate: float = 1
var current_alt_fire_rate: float = 1
var current_ammo: int = -1
var max_ammo: int = -1
var current_recoil: float = 1
var current_alt_recoil: float = 1
var current_reload_time: float = 1
var current_weak_point_mult: float = 1
var current_crit_mult: float = 1
var current_switch_time: float = 1
var current_power: float = 0
var current_crit_chance: float = 0.25:
	set(value):
		current_crit_chance = clampf(value, 0, 1)
var is_reloading: bool = false
## This deals with the fire rate
var is_shoot_cooldown: bool = false

enum Stats {
	DAMAGE,
	ALT_DAMAGE,
	FIRERATE,
	ALT_FIRERATE,
	CURRENTAMMO,
	MAXAMMO,
	RECOIL,
	RELOADTIME,
	WEAKPOINTMULT,
	CRITMULT,
	SWITCHTIME,
	POWER,
	CRITCHANCE
}

@export_group("Important Nodes")
@export var animation_player: AnimationLibrary


func _init() -> void:
	# Should see if this actually gets freed if the player gets removed to prevent memory leaks
	if is_instance_valid(shoot_script_1):
		shoot_script_1.weapon_resource = self
		shoot_script_1.player = player
	if is_instance_valid(shoot_script_2):
		shoot_script_2.weapon_resource = self
		shoot_script_2.player = player
	if is_instance_valid(ability_script):
		ability_script.weapon_resource = self
		ability_script.player = player
	if is_instance_valid(reload_script):
		reload_script.weapon_resource = self
		reload_script.player = player

## This will just apply default values
func reset_stats() -> void:
	current_damage = _damage
	current_accuracy = _accuracy
	current_alt_accuracy = _alt_accuracy
	current_alt_damage = _alt_damage
	current_fire_rate = _fire_rate
	current_alt_fire_rate = _alt_fire_rate
	current_ammo = _ammo
	max_ammo = _ammo
	current_recoil = _recoil
	current_alt_recoil = _alt_recoil
	current_reload_time = _reload_time
	current_weak_point_mult = _weak_point_mult
	current_crit_mult = _crit_mult
	current_switch_time = _switch_time
	current_power = power
	current_crit_chance = _crit_chance

func _reset_specific_stat(stat: Stats) -> void:
	match stat:
		Stats.DAMAGE:
			current_damage = _damage
		Stats.ALT_DAMAGE:
			current_alt_damage = _alt_damage
		Stats.FIRERATE:
			current_fire_rate = _fire_rate
		Stats.ALT_FIRERATE:
			current_alt_fire_rate = _alt_fire_rate
		Stats.CURRENTAMMO:
			current_ammo = _ammo
		Stats.MAXAMMO:
			max_ammo = _ammo
		Stats.RECOIL:
			current_recoil = _recoil
		Stats.RELOADTIME:
			current_reload_time = _reload_time
		Stats.WEAKPOINTMULT:
			current_weak_point_mult = _weak_point_mult
		Stats.CRITMULT:
			current_crit_mult = _crit_mult
		Stats.SWITCHTIME:
			current_switch_time = _switch_time
		Stats.POWER:
			current_power = power
		Stats.CRITCHANCE:
			current_crit_chance = _crit_chance
		_:
			push_warning("This is not a current stat")

func can_shoot() -> bool:
	if current_ammo > 0 and !is_reloading and !is_shoot_cooldown and can_all_fire:
		return true
	return false

func get_primary_damage() -> float:
	var damage: float = current_damage
	var chance: float = randf()
	#print("chance: %s / %s" % [current_crit_chance, snappedf(chance, 0.01)])
	if current_crit_chance > chance:
		damage *= current_crit_mult
	return damage

func get_alt_damage() -> float:
	var damage: float = current_alt_damage
	if current_crit_chance <= randf():
		damage *= current_crit_mult
	return damage

func do_shoot_script_1() -> void:
	if is_instance_valid(shoot_script_1):
		shoot_script_1.use_effect()


func do_shoot_script_2() -> void:
	if is_instance_valid(shoot_script_2):
		shoot_script_2.use_effect()


func do_ability_script() -> void:
	if is_instance_valid(ability_script):
		ability_script.use_effect()


func do_reload_script() -> void:
	if is_instance_valid(reload_script):
		reload_script.use_effect()
