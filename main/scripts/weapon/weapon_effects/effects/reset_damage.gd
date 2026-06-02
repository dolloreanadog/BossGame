extends WeaponEffect

func use_effect() -> void:
	weapon_resource.current_damage = weapon_resource._damage
