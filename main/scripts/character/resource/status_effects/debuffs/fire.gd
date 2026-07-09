extends StatusEffect
class_name FireEffect

@export var damage: float = 5

func _effect() -> void:
	character.health.damage(damage)

func _start_effect() -> void:
	pass

func _end_effect() -> void:
	pass
