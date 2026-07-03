extends Label

@export var player: PlayerCharacter

func _process(delta: float) -> void:
	text = "Speed: %s | Speed Multiplier: %s" % [player.current_speed, player.movement_multiplier]

func _ready() -> void:
	pass
	#await get_tree().create_timer(1).timeout
	#player.apply_movement_multiplier(1)
	#await get_tree().create_timer(3).timeout
	#player.apply_movement_multiplier(1)
	#await get_tree().create_timer(3).timeout
	#player.apply_movement_multiplier(-3)
	#await get_tree().create_timer(3).timeout
	#player.reset_movement_multiplier()
	#await get_tree().create_timer(3).timeout
	#player.apply_movement_multiplier(-0.5)
