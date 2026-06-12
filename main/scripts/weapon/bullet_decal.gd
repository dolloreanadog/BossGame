extends Decal
class_name BulletDecal

# TODO: Have it in settings so we can disable placing of these.

@export var duration: float = 1

func _ready() -> void:
	await get_tree().create_timer(duration).timeout
	queue_free()
