@abstract
extends Resource
class_name StatusEffect

## Either enemy or player, apply debuff
var character: Character

## How long it lasts
var duration: float = 1
var times: int = 1:
	get():
		return times
	set(value):
		if times <= 0:
			done.emit()

## Emits when times <= 0. When status effect wears off
signal done

func _init(new_character: Character) -> void:
	character = new_character

@abstract
## This will run every
func activate() -> void;
