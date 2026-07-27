@icon("uid://cbrc6nruckpqs")
extends PlayerComponent
## This is an important node which checks between server and client. So we don't see them doing any naughty stuff
class_name ServerComponent

@export var ammo_leniency: int

func check_ammo() -> void:
	pass

## Returns false if the server believes any of these are false
## @deprecated: We using server-side damage
func check_invalid_damage() -> bool:
	if !character.health.is_dead:
		return false
	if player.weapon_manager.is_holding_primary:
		if player.weapon_manager.weapon_1.current_ammo <= 0:
			return false
	else:
		if player.weapon_manager.weapon_2.current_ammo <= 0:
			return false
	return true
