@abstract
extends BoneAttachment3D
## Base Weapon Class which all weapons inherit from
class_name Weapon

# INFO: We might want to modulize the gun a bit, for example seperate the fire1 & fire2 to seperate scripts

## What kind of weapon it is
enum WeaponType {
	AR, ## An Assault Rifle
	SMG, ## An Semi Automatic Gun
	SHOTGUN, ## Short range big damage
	SNIPER, ## Long Range power gun
	MG, ## Powerful cumbersone sustain gun
	PISTOL ## decent secondary
	}

## INFO: These are the default values we change in editor and SHOULD NOT BE EDITED IN GAME
@warning_ignore("unused_private_class_variable")
@export var _weapon_id: int = 0
@warning_ignore("unused_private_class_variable")
@export var _weapon_name: String = "Weapon"
@export_group("Attributes")
@export var _damage: float = 1
@export var _fire_rate: float = 1
## weight will slow down the player
@export var _weight: float = 1
@export var _ammo: int = 10
@export var _recoil: float = 1
@export var _reload_time: float = 1
## A multiplier which slows down the player when reloading
@export var _reload_slow: float = 1
@export var _weak_point_mult: float = 1
@export var _crit_mult: float = 1
@export var _switch_time: float = 1
# TODO: sometimes maybe we want to give a debuff to the boss, need a way to implement
# TODO: also we can implement a counter


## INFO: These are the adjustable values we can change in game
var current_damage: float = 1
var current_fire_rate: float = 1
var current_weight: float = 1
var current_reload_time: float = 1
var current_reload_slow: float = 1
var current_weak_point_mult: float = 1
var current_crit_mult: float = 1
var current_switch_time: float = 1


@export_group("Important Nodes")
@export var animation_player: AnimationPlayer


## This will just apply default values
func _apply_to_current() -> void:
	current_damage = _damage
	current_fire_rate = _fire_rate
	current_weight = _weight
	current_reload_time = _reload_time
	current_reload_slow = _reload_slow
	current_weak_point_mult = _weak_point_mult
	current_crit_mult = _crit_mult
	current_switch_time = _switch_time


@abstract
func fire1() -> void;


@abstract 
func fire2() -> void;
