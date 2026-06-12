@abstract
extends Timer
class_name StatusEffect

## Either enemy or player, apply debuff
var character: Character

@export var times: int = 1:
	get():
		return times
	set(value):
		if times <= 0:
			done.emit()
@export var is_pure: bool = false

## Emits when times <= 0. When status effect wears off
signal done

func _init(new_character: Character) -> void:
	character = new_character

@abstract
## This will run every
func activate() -> void;
