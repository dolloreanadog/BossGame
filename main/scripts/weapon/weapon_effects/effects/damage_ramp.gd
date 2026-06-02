extends WeaponEffect

func use_effect() -> void:
	weapon_resource.current_damage += 1

# I think it should be fine since it is being done by a resource from the server
