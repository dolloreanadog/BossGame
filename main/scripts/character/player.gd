extends Character
class_name PlayerCharacter

var player_name: String = "something"
var steam_id: int = 0

## see if the player is in combat. Used
var is_in_combat: bool

signal Fire1
signal Fire2

func _physics_process(delta: float) -> void:
	pass

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Fire1"):
		Fire1.emit()
	if event.is_action_pressed("Fire2"):
		Fire2.emit()
