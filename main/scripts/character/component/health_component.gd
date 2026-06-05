extends CharacterComponent
class_name HealthComponent

@export var _max_health: float = 100
@export var _max_shield: float = 100
## [b]DO NOT CHANGE THIS IN-GAME[/b] [br]
## How much damage the player will take. Lower the value the lower the damage. Higher the value the higher the damage.
@export var _damage_multiplier: float = 1
var is_dead: bool = false
var current_health: float = 100:
	set(value):
		if is_dead: return
		current_health = value
		clampf(current_health, 0, _max_health)
		check_death()
		health_changed.emit(current_health + current_shield)
var current_shield: float = 0:
	set(value):
		if is_dead: return
		current_shield = value
		clampf(current_shield, 0, _max_shield)
		health_changed.emit(current_health + current_shield)
## How much damage the player will take. Lower the value the lower the damage. Higher the value the higher the damage.
var current_damage_multiplier: float = 0:
	set(value):
		current_damage_multiplier = value

signal died
signal revived
signal shield_broken
signal healed(amount: float, new_health: float)
signal shielded(amount: float, new_shield: float)
signal damaged(amount: float, new_health: float)
signal health_changed(amount: float)

func _ready() -> void:
	current_health = _max_health
	current_shield = 0
	current_damage_multiplier = _damage_multiplier


func heal(amount: float) -> void:
	if is_dead:
		return
	current_health += amount
	healed.emit(amount, current_health)


func shield(amount: float) -> void:
	if is_dead:
		return
	current_shield += amount
	shielded.emit(amount, current_shield)


func remove_shield(amount: float) -> void:
	if is_dead:
		return
	current_shield -= amount


## Adds to the [HealthComponent.current_damage_multiplier]
func add_vulnerability(amount: float) -> void:
	if is_dead:
		return
	current_damage_multiplier += amount


## Removes from the [HealthComponent.current_damage_multiplier]
func remove_vulnerability(amount: float) -> void:
	if is_dead:
		return
	current_damage_multiplier -= amount


func damage(amount: float, is_pure: float = false) -> void:
	if is_dead: return
	if !is_pure:
		if current_shield > 0:
			current_shield -= amount * (current_damage_multiplier)
			# remove some damage from what got shielded
			clampf(amount - current_shield, 0, INF)
			if current_shield <= 0:
				shield_broken.emit()
		current_health -= amount * (current_damage_multiplier)
	else:
		current_health -= amount
	damaged.emit(amount, current_health)


func revive(heal_amount: float, shield_amount: float, resist_amount: float) -> void:
	is_dead = false
	heal(heal_amount)
	shield(shield_amount)
	add_vulnerability(resist_amount)
	revived.emit()


func check_death() -> void:
	if current_health <= 0:
		is_dead = true
		died.emit()

@rpc("any_peer", "call_local", "reliable")
func _kill_person() -> void:
	pass

## TODO: Test if we make time like 10 seconds, if it freezes the game.
func add_temporary_shield(amount: float, time: float) -> void:
	shield(amount)
	await get_tree().create_timer(time).timeout
	remove_shield(amount)


## TODO: Test if we make time like 10 seconds, if it freezes the game.
func add_temporary_vulnerability(amount: float, time: float) -> void:
	add_vulnerability(amount)
	await get_tree().create_timer(time).timeout
	remove_vulnerability(amount)
