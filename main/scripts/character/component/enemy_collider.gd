extends CollisionShape3D
class_name EnemyCollider

@export var enemy: EnemyCharacter

# TODO: We need some way of getting the damage multiplier

## how much the damage is multiplied if this hits
@export var damage_multiplier: float = 1

signal Hit(amount: float, weak_point_mult: float)

func _ready() -> void:
	Hit.connect(_hit_effect)

func _hit_effect(amount: float, weak_point_mult: float) -> void:
	var damage: float
	if damage_multiplier > 1:
		damage = (amount * weak_point_mult) * damage_multiplier
	else:
		damage = amount * damage_multiplier
	print("Enemy Hit For %s" % [damage])
	enemy.health.damage(damage)
