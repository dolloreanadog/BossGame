extends StatusEffect
class_name StunEffect

func _effect() -> void:
	pass

func _start_effect() -> void:
	player.can_control = false
	print("can control = false")

func _end_effect() -> void:
	player.can_control = true
	print("can control = true")
