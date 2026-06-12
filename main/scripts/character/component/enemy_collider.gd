extends CollisionShape3D
class_name EnemyCollider

@export var enemy: EnemyCharacter

# TODO: We need some way of getting the damage multiplier

## how much the damage is multiplied if this hits
var damage_multiplier: float = 1

signal Hit(amount: float)

func _ready() -> void:
	Hit.connect(_hit_effect)

func _hit_effect(amount: float) -> void:
	print("Enemy Hit")
	enemy.health.damage(amount)
