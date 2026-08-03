@abstract
@icon("uid://dgd73cpjtpfaa")
extends Resource
## Make sure this is local_to_scene. Resource containing all information on the weapon. [br]
## Does not directly grab from _*
class_name NewWeapon

## Somewhat follow weapon.gd
## TODO: Document everything

#region Variables
## What kind of weapon it is
enum WeaponType {
	AR, ## An Assault Rifle
	PISTOL, ## decent secondary
	SNIPER, ## Long Range power gun
	MG, ## Powerful cumbersone sustain gun, but heavy
	SMG, ## An Semi Automatic Gun, less damaging, variable amounts of ammo and fast
	SHOTGUN, ## Short range big damage
	}

enum weapon_stat {ALL_FIRE, DAMAGE, AMMO_CONSUMPTION, FIRE_RATE, RECOIL, SHOOT_SLOW_DURATION, RELOAD_TIME, WEAK_POINT_MULT, CRIT_MULT, CRIT_CHANCE, RANGE, IS_PURE}

@export var weapon_id: int = 0
@export var weapon_name: String = "Weapon"
@export var type: WeaponType


#region Visuals
@export_group("Visuals")
## Contains a weapon_ui_element, which is a gauge and text.
@export var special_hud_element: PackedScene
@export var bullet_decal: PackedScene
## TODO: Need to figure out how we can implement tracer particles
@export var tracer: PackedScene
## TODO: Need to figure out how we can implement the flash from firing gun [br]
## Current plan is to have some marker 3d, & put it in the location where the barrel is located
## Or have a small
@export var muzzle_flash: ParticleProcessMaterial
## TODO: This does nothing, but needs to be implemented in weapon manager [br]
## This is the effect
@export var hit_effect: ParticleProcessMaterial
@export_subgroup("World Model")
@export var world_mesh: PackedScene
@export var world_position: Vector3
@export var world_rotation: Vector3
## TODO: Look to MuzzleFlashMarker in WeaponSlot
@export var world_flash_position_offset: Vector3

@export_subgroup("View Model")
@export var view_mesh: PackedScene
@export var view_position: Vector3
@export var view_rotation: Vector3
@export var view_flash_position_offset: Vector3
#endregion

#region Sounds
@export_group("Sounds")
## Sound that plays when reloading
@export var _sound_reload: AudioStream
## Sound that plays when shooting 1
@export var _sound_shoot1: AudioStream
## Sound that plays when shooting 2
@export var _sound_shoot2: AudioStream
## This is an extra sound effect we can use in inherited guns, can create how many we want.
#@export var _sound_extra: AudioStream
#endregion

#region Attributes
@export_group("Attributes")
@export var can_all_fire: bool = true
## [b] DO NOT MODIFY [/b] [br]
## Decides whether the gun can use secondary fire
@export var _can_alt_fire: bool = false
@export var switch_time: float = 1
@export var move_speed: float = 5
## The set speed when they reload
@export var reload_slow: float = 4:
	set(value):
		value = maxf(0.0, value) # So we can't be below 0
@export var _reload_time: float = 1:
	set(value):
		value = maxf(0.05, value) # So we can't be below 0
@export var ammo: int = 5
#region Shoot 1
@export_subgroup("Shoot1")
@export var _damage_1: float = 1: # To maybe add some redundancy, add a check if it is used during runtime deny it.
	set(value):
		if OS.is_debug_build():
			_damage_1 = value
		else:
			push_warning("Cannot modify value in release runtime.")
## How much damage can deviate per shot
@export var _damage_variance_1: float = 0
@export var _ammo_consumption_1: int = 1
@export_range(0, 100, 0.01) var _accuracy_1: float = 100:
	set(value):
		_accuracy_1 = value
		clampf(_accuracy_1, 0, 100)
@export var _spread_angle_1: float = 0
@export var pellet_count_1: int = 1
@export var _manual_fire_1: bool = false
@export var _fire_rate_1: float = 0.5
@export var _recoil_1: float = 1
## The set speed when they shoot, after it some time reset it
@export var shoot_slow_1: float = 4.5:
	set(value):
		value = maxf(0.0, value) # So we can't be below 0
@export_range(0, 5) var shoot_slow_duration_1: float = 0.5:
	set(value):
		value = maxf(0.01, value)
@export var _weak_point_mult_1: float = 1.25:
	set(value):
		value = maxf(0.0, value) # So we can't be below 0.0
@export var _crit_mult_1: float = 1.5:
	set(value):
		value = maxf(0.0, value) # So we can't be below 0.0
@export_range(0, 1) var _crit_chance_1: float = 0:
	set(value):
		_crit_chance_1 = clampf(value, 0, 1)
@export var _raycast_range_1: float = -10:
	set(value):
		value = minf(0, value) # So we can't be above 0, or else player shoots backwards
## If the damage can pierce through resistance and shield
@export var _is_pure_1: bool = false
#endregion

#region Shoot 2
@export_subgroup("Shoot2")
@export var _damage_2: float = 1
## How much damage can deviate per shot
@export var _damage_variance_2: float = 0
@export var _ammo_consumption_2: int = 1
@export_range(0, 100, 0.01) var _accuracy_2: float = 100:
	set(value):
		_accuracy_2 = value
		clampf(_accuracy_2, 0, 100)
@export var _spread_angle_2: float = 0
@export var pellet_count_2: int = 1
@export var _manual_fire_2: bool = false
@export var _fire_rate_2: float = 0.5
@export var _recoil_2: float = 1
## The set speed when they shoot
@export var shoot_slow_2: float = 4.5:
	set(value):
		value = maxf(0.0, value) # So we can't be below 0
@export_range(0, 5) var shoot_slow_duration_2: float = 0.5:
	set(value):
		value = maxf(0.01, value)
## The set speed when they reload
@export var _weak_point_mult_2: float = 1.25:
	set(value):
		value = maxf(1.0, value) # So we can't be below 1.0
@export var _crit_mult_2: float = 1.5
@export_range(0, 1) var _crit_chance_2: float = 0:
	set(value):
		_crit_chance_2 = clampf(value, 0, 1)
@export var _raycast_range_2: float = -10:
	set(value):
		value = minf(0, value) # So we can't be above 0, or else player shoots backwards
## If the damage can pierce through resistance and shield
@export var _is_pure_2: bool = false
#endregion

#region Ability
@export_group("Ability")
## [b] DO NOT MODIFY [/b] [br]
## The reason why we want a default value for this is to add some kind of silence status effect that silences abilities.
@export var _can_use_ability: bool = false
## How much damage the ability does
@export var _damage_ability: int = 0
## Look into Status Effect Index to see what status effect to apply, have server handle applying [br]
## We can definitely look into playing creating new variables of this in inherited guns.
@export var _self_status_effect: StringName
## [b] DO NOT MODIFY [/b] [br]
## modify [NewWeapon.ability_cooldown] instead. Can have
@export var _ability_cooldown: int = 1
#endregion
#endregion

#region Current Attributes
var current_ammo: int = 5:
	set(value):
		current_ammo = maxi(0, value) # Don't go below 0
var is_reloading: bool = false
var is_fire_rate_locked: bool = false
var power: float = 0

var current_reload_time_mult: float = 1
var current_reload_time_add: float = 0

var reload_animation_speed: float = 1

## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_reload_time: float:
	get():
		var value: float = 0
		value = (_reload_time + current_reload_time_add) * current_reload_time_mult
		return value

#region Current Shoot 1
#region Modifiers
# Protoytpye, theoretically better. Has either "Mult" or "Add"
#var current_damage_dict_1: Dictionary[String, float] = {"Mult": 1, "Add": 0}

var current_damage_mult_1: float = 1
var current_damage_add_1: float = 0

## This modifies [member NewWeapon._ammo_consumption_1], So if it is one, this either adds 1 or -1. [br]
## Looks like: [member NewWeapon._ammo_consumption_1] + [member current_ammo_consumption_add_1]
var current_ammo_consumption_add_1: int = 0

var current_accuracy_mult_1: float = 1
var current_accuracy_add_1: float = 0

var current_fire_rate_mult_1: float = 1
var current_fire_rate_add_1: float = 0

var current_recoil_mult_1: float = 1
var current_recoil_add_1: float = 0



var current_weak_point_mult_mult_1: float = 1
var current_weak_point_mult_add_1: float = 0

var current_crit_mult_mult_1: float = 1
var current_crit_mult_add_1: float = 0

var current_crit_chance_mult_1: float = 1
var current_crit_chance_add_1: float = 0

var current_raycast_range_mult_1: float = 1
var current_raycast_range_add_1: float = 0

var current_is_pure_1: bool = false
#endregion
## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_damage_1: float: # account for damage variance and crits
	get():
		var value: float = 0
		var chance: float = randf()
		@warning_ignore("narrowing_conversion")
		value = (_damage_1 + current_damage_add_1 + randi_range(-_damage_variance_1, _damage_variance_1)) * current_damage_mult_1 
		#print("chance: %s / %s" % [current_crit_chance, snappedf(chance, 0.01)])
		if current_crit_chance_1 > chance:
			value *= current_crit_mult_1
		return maxf(0, value) # do not go below 0


## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_ammo_consumption_1: int = 0:
	get():
		var value: int = 0
		value = (_ammo_consumption_1 + current_ammo_consumption_add_1)
		return maxi(0, value) # do not go below 0

## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_accuracy_1: float:
	get():
		var value: float = 0
		value = (_accuracy_1 + current_accuracy_add_1) * current_accuracy_mult_1
		return clampf(value, 0, 100) # stick to 0-100 range


## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_fire_rate_1: float:
	get():
		var value: float = 0
		value = (_fire_rate_1 + current_fire_rate_add_1) * current_fire_rate_mult_1
		return clampf(value, 0, 100) # stick to 0-100 range


## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_recoil_1: float:
	get():
		var value: float = 0
		value = (_recoil_1 + current_recoil_add_1) * current_recoil_mult_1
		return value


## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_weak_point_mult_1: float:
	get():
		var value: float = 0
		value = (_weak_point_mult_1 + current_weak_point_mult_add_1) * current_weak_point_mult_mult_1
		return value


## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_crit_mult_1: float:
	get():
		var value: float = 0
		value = (_crit_mult_1 + current_crit_mult_add_1) * current_crit_mult_mult_1
		return value


## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_crit_chance_1: float:
	get():
		var value: float = 0
		value = (_crit_chance_1 + current_crit_chance_add_1) * current_crit_chance_mult_1
		return value

## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_raycast_range_1: float:
	get():
		var value: float = 0
		value = (_raycast_range_1 + current_raycast_range_add_1) * current_raycast_range_mult_1
		return minf(0, value)
#endregion
#region Current Shoot 2
#region Modifiers
var current_damage_mult_2: float = 1
var current_damage_add_2: float = 0

## This modifies [member NewWeapon._ammo_consumption_2], So if it is one, this either adds 1 or -1. [br]
## Looks like: [member NewWeapon._ammo_consumption_2] + [member current_ammo_consumption_add_2]
var current_ammo_consumption_add_2: int = 0

var current_accuracy_mult_2: float = 1
var current_accuracy_add_2: float = 0

var current_fire_rate_mult_2: float = 1
var current_fire_rate_add_2: float = 0

var current_recoil_mult_2: float = 1
var current_recoil_add_2: float = 0

var current_weak_point_mult_mult_2: float = 1
var current_weak_point_mult_add_2: float = 0

var current_crit_mult_mult_2: float = 1
var current_crit_mult_add_2: float = 0

var current_crit_chance_mult_2: float = 1
var current_crit_chance_add_2: float = 0

var current_raycast_range_mult_2: float = 1
var current_raycast_range_add_2: float = 0

var current_is_pure_2: bool = false
#endregion
## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_damage_2: float:
	get():
		var value: float = 0
		var chance: float = randf()
		@warning_ignore("narrowing_conversion")
		value = (_damage_2 + current_damage_add_2 + randi_range(-_damage_variance_2, _damage_variance_2)) * current_damage_mult_2 
		#print("chance: %s / %s" % [current_crit_chance, snappedf(chance, 0.01)])
		if current_crit_chance_2 > chance:
			value *= current_crit_mult_2
		return maxf(0, value) # do not go below 0

## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_ammo_consumption_2: int = 0:
	get():
		var value: int = 0
		value = (_ammo_consumption_2 + current_ammo_consumption_add_2)
		return maxi(0, value) # do not go below 0

## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_accuracy_2: float:
	get():
		var value: float = 0
		value = (_accuracy_2 + current_accuracy_add_2) * current_accuracy_mult_2
		return clampf(value, 0, 100) # stick to 0-100 range

## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_fire_rate_2: float:
	get():
		var value: float = 0
		value = (_fire_rate_2 + current_fire_rate_add_2) * current_fire_rate_mult_2
		return clampf(value, 0, 100) # stick to 0-100 range


## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_recoil_2: float:
	get():
		var value: float = 0
		value = (_recoil_2 + current_recoil_add_2) * current_recoil_mult_2
		return value


## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_weak_point_mult_2: float:
	get():
		var value: float = 0
		value = (_weak_point_mult_2 + current_weak_point_mult_add_2) * current_weak_point_mult_mult_2
		return value


## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_crit_mult_2: float:
	get():
		var value: float = 0
		value = (_crit_mult_2 + current_crit_mult_add_2) * current_crit_mult_mult_2
		value = clampf(value, 0, 1)
		return value


## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_crit_chance_2: float:
	get():
		var value: float = 0
		value = (_crit_chance_2 + current_crit_chance_add_2) * current_crit_chance_mult_2
		return value


## [b]Unmodifiable[/b][br]
## This is what is actually grab since it will automatically add ontop modifiers.
var current_raycast_range_2: float:
	get():
		var value: float = 0
		value = (_raycast_range_2 + current_raycast_range_add_2) * current_raycast_range_mult_2
		return minf(0, value)
#endregion
#region Current Ability
var can_use_ability: bool = true
var stop_ability_cooldown: bool = false

#endregion
#endregion

#region Extra
## We can use player for some effects later
var player: PlayerCharacter
## This is a general variable that can be used for various purposes
var _animation_player: AnimationPlayer
#var hud_element: weapon_ui_element
#endregion
#endregion

func _init() -> void:
	reset_all_stats() # So we can make sure weapon is current

## Resets a specific stat
func reset_stat(stat: weapon_stat, is_alt: bool) -> void:
	match stat:
		weapon_stat.ALL_FIRE:
			can_all_fire = true
		weapon_stat.DAMAGE:
			if is_alt:
				current_damage_mult_1 = 1
				current_damage_add_1 = 0
			else:
				current_damage_mult_2 = 1
				current_damage_add_2 = 0
		weapon_stat.AMMO_CONSUMPTION:
			if is_alt:
				current_ammo_consumption_add_1 = 0
				current_ammo_consumption_add_2 = 0
		weapon_stat.AMMO_CONSUMPTION:
			if is_alt:
				current_accuracy_mult_1 = 1
				current_accuracy_add_1 = 0
			else:
				current_accuracy_mult_2 = 1
				current_accuracy_add_2 = 0
		weapon_stat.FIRE_RATE:
			if is_alt:
				current_fire_rate_mult_1 = 1
				current_fire_rate_add_1 = 0
			else:
				current_fire_rate_mult_2 = 1
				current_fire_rate_add_2 = 0
		weapon_stat.RECOIL:
			if is_alt:
				current_recoil_mult_1 = 1
				current_recoil_add_1 = 0
			else:
				current_recoil_mult_2 = 1
				current_recoil_add_2 = 0
		weapon_stat.RELOAD_TIME:
			if is_alt:
				current_reload_time_mult = 1
				current_reload_time_add = 0
		weapon_stat.WEAK_POINT_MULT:
			if is_alt:
				current_weak_point_mult_mult_1 = 1
				current_weak_point_mult_add_1 = 0
			else:
				current_weak_point_mult_mult_2 = 1
				current_weak_point_mult_add_2 = 0
		weapon_stat.CRIT_MULT:
			if is_alt:
				current_crit_mult_mult_1 = 1
				current_crit_mult_add_1 = 0
			else:
				current_crit_mult_mult_2 = 1
				current_crit_mult_add_2 = 0
		weapon_stat.CRIT_CHANCE:
			if is_alt:
				current_crit_chance_mult_1 = 1
				current_crit_chance_add_1 = 0
			else:
				current_crit_chance_mult_2 = 1
				current_crit_chance_add_2 = 0
		weapon_stat.RANGE:
			if is_alt:
				current_raycast_range_mult_1 = 1
				current_raycast_range_add_1 = 0
			else:
				current_raycast_range_mult_2 = 1
				current_raycast_range_add_2 = 0
		weapon_stat.IS_PURE:
			if is_alt:
				current_is_pure_1 = _is_pure_1
			else:
				current_is_pure_2 = _is_pure_2

## Resets all stats
func reset_all_stats() -> void:
	can_all_fire = true
	
	current_damage_mult_1 = 1
	current_damage_add_1 = 0
	current_ammo_consumption_add_1 = 0
	current_accuracy_mult_1 = 1
	current_accuracy_add_1 = 0
	current_fire_rate_mult_1 = 1
	current_fire_rate_add_1 = 0
	current_recoil_mult_1 = 1
	current_recoil_add_1 = 0
	current_reload_time_mult = 1
	current_reload_time_add = 0
	current_weak_point_mult_mult_1 = 1
	current_weak_point_mult_add_1 = 0
	current_crit_mult_mult_1 = 1
	current_crit_mult_add_1 = 0
	current_crit_chance_mult_1 = 1
	current_crit_chance_add_1 = 0
	current_raycast_range_mult_1 = 1
	current_raycast_range_add_1 = 0
	
	current_damage_mult_2 = 1
	current_damage_add_2 = 0
	current_ammo_consumption_add_2 = 0
	current_accuracy_mult_2 = 1
	current_accuracy_add_2 = 0
	current_fire_rate_mult_2 = 1
	current_fire_rate_add_2 = 0
	current_recoil_mult_2 = 1
	current_recoil_add_2 = 0
	current_weak_point_mult_mult_2 = 1
	current_weak_point_mult_add_2 = 0
	current_crit_mult_mult_2 = 1
	current_crit_mult_add_2 = 0
	current_crit_chance_mult_2 = 1
	current_crit_chance_add_2 = 0
	current_raycast_range_mult_2 = 1
	current_raycast_range_add_2 = 0

## @deprecated: Moved to modifier system, unusable now. The stats now has either [code]*_add[/code] or [code]*_mult[/code]. which are very modifiable.
func change_stat(stat: weapon_stat, is_alt: bool) -> void:
	pass

## These are variables that should be tweaked over the normal varaibles.
#region Current Variables
#region Shoot 1

#endregion
#region Shoot 2
#endregion
#endregion

#region Server Methods
func can_shoot() -> bool:
	if current_ammo > 0 and !is_reloading and can_all_fire and is_fire_rate_locked:
		return true
	return false

## See if there is an ability or not
func is_there_ability() -> bool:
	return _can_use_ability

## @deprecated: [method NewWeapon.current_damage_1] should be used over this. This will return 0.
func get_primary_damage() -> float:
	var damage: float = 0 #current_damage
	var chance: float = randf()
	#print("chance: %s / %s" % [current_crit_chance, snappedf(chance, 0.01)])
	if current_crit_chance_1 > chance:
		damage *= current_crit_mult_1
	return damage

## @deprecated: [method NewWeapon.current_damage_2] should be used over this. This will return 0.
func get_alt_damage() -> float:
	var damage: float = 0 #current_alt_damage
	var chance: float = randf()
	if current_crit_chance_2 > chance:
		damage *= current_crit_mult_2
	return damage

## This is a server method, it's an rpc because authority calls the ability, so we need to send to server [br]
## Then we do the calculations and send the confirmations back to the player like visuals and sound. [br][br]
## This should be how the function should be usually structured:
## [codeblock]
## func use_ability() -> void:
## 	if player.multiplayer.is_server():
## 	do stuff
## 	Then sync it like sync_use_ability.rpc(stuff, stuff)
## [/codeblock]
@abstract
@rpc("any_peer", "call_local", "reliable")
func use_ability() -> void;


## This is a server method, it's an rpc because authority calls the shooting, so we need to send to server [br]
## Then we do the calculations and send the confirmations back to the player like visuals and sound.
@abstract
@rpc("any_peer", "call_local", "reliable")
func shoot_1() -> void;


## This is a server method, it's an rpc because authority calls the shooting, so we need to send to server [br]
## Then we do the calculations and send the confirmations back to the player like visuals and sound.
@abstract
@rpc("any_peer", "call_local", "reliable")
func shoot_2() -> void;


## This is a server method, it's an rpc because authority calls the reload, so we need to send to server [br]
## Then we do the calculations and send the confirmations back to the player like visuals and sound.
@abstract
@rpc("any_peer", "call_local", "reliable")
func reload() -> void;
#endregion

## These are all are private since only this script needs to use these.
#region All Clients
## Accepts assortment of values.
## If not player.is_multiplayer_authority(): 
@abstract
@rpc("any_peer", "call_local", "reliable")
func _sync_client_use_ability(...args: Array) -> void; 


## Accepts assortment of values.
## If not player.is_multiplayer_authority():
@abstract
@rpc("any_peer", "call_local", "reliable")
func _sync_client_shoot1(...args: Array) -> void; 


## Accepts assortment of values.
## If not player.is_multiplayer_authority():
@abstract
@rpc("any_peer", "call_local", "reliable")
func _sync_client_shoot2(...args: Array) -> void; 


## Accepts assortment of values.
## If not player.is_multiplayer_authority():
@abstract
@rpc("any_peer", "call_local", "reliable")
func _sync_client_reload(...args: Array) -> void; 
#endregion

## These are all are private since only this script needs to use these.
## This code region only applies to the one that shot preferably, show icon and ammo on cooldown.
#region Authority
## Accepts assortment of values.
## If player.is_multiplayer_authority():
@abstract
@rpc("any_peer", "call_local", "reliable")
func _sync_authority_use_ability(...args: Array) -> void;


## Accepts assortment of values.
## If player.is_multiplayer_authority():
@abstract
@rpc("any_peer", "call_local", "reliable")
func _sync_authority_shoot1(...args: Array) -> void;


## Accepts assortment of values.
## If player.is_multiplayer_authority():
@abstract
@rpc("any_peer", "call_local", "reliable")
func _sync_authority_shoot2(...args: Array) -> void;


## Accepts assortment of values.
## If player.is_multiplayer_authority():
@abstract
@rpc("any_peer", "call_local", "reliable")
func _sync_authority_reload(...args: Array) -> void;
#endregion
