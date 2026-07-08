@icon("uid://bmpghfb1tyte5")
@abstract
extends Resource
## a limited effect that buffs or debuffs a character. [br]
## Make sure to add it global status index
class_name StatusEffect

## Either enemy or player, apply debuff
var character: Character

enum Conditionals {
	START_END_SAME, ##  It will do the same effect at the start and end
	START_END_DIFF, ## It will do the effect at start and end oppositely
	CONSTANT,  ## For every second, something happens
	START, ## It gives an effect at the start
	END ## It gives an effect at the end
	}

## How many Stacks, can only be a minimum of one
var stacks: int = 1
## Name of the effect
@export var name: StringName
## How many of it can have
@export var max_stacks: int = 1
## The UI Scene to show the player the effect
@export var UI: PackedScene
## How long until it wears off
@export var time: int = 1:
	get():
		return time
	set(value):
		if time <= 0:
			done.emit()
@export var is_pure: bool = false

## Emits when time <= 0. When status effect wears off
signal done

func _init(new_character: Character) -> void:
	character = new_character


## This will run every second, see status manager
@rpc("any_peer", "call_local", "reliable")
func activate() -> void:
	_effect()
	time -= 1

@abstract
func _effect() -> void;
