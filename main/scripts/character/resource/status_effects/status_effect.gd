@icon("uid://bmpghfb1tyte5")
@abstract
extends Resource
## a limited effect that buffs or debuffs a character. [br]
## Make sure to add it global status index
class_name StatusEffect

## Either enemy or player, apply debuff
var character: Character
var player: PlayerCharacter

enum Conditionals {
	START_END_SAME, ##  It will do the same effect at the start and end
	START_END_DIFF, ## It will do the effect at start and end oppositely
	CONSTANT,  ## For every second, something happens
	START, ## It gives an effect at the start
	END ## It gives an effect at the end
	}

# TODO: Screw the @export and creating a resource file, DO NOT CREATE

## How many Stacks, can only be a minimum of one
var stacks: int = 1
var _has_start_activated: bool = false
## Name of the effect
@export var name: StringName 
## How many of it can have
@export var max_stacks: int = 1
## How long until it wears off
@export var time: int = 1:
	get():
		return time
	set(value):
		if time <= 0:
			done.emit()
@export var is_pure: bool = false
## when the status should do something
@export var condition: Conditionals

@export_subgroup("Visuals")
@export var icon: Texture2D
@export var hover_text: String
var visualized_status: StatusUI

## Emits when time <= 0. When status effect wears off
signal done
signal activated(current_time: int)

func _init(new_character: Character) -> void:
	resource_local_to_scene = true
	character = new_character

## This will run every second, see status manager
@rpc("any_peer", "call_local", "reliable")
func activate() -> void:
	match condition:
		Conditionals.START_END_SAME:
			_effect()
		Conditionals.START_END_DIFF:
			if !_has_start_activated:
				_start_effect()
				_has_start_activated = true
			elif time <= 0:
				_end_effect()
		Conditionals.CONSTANT:
			_effect()
		Conditionals.START:
			_effect()
		Conditionals.END:
			_effect()
		_:
			push_error("No Condition fits")
	
	print("Status Effect Activated")
	time -= 1
	activated.emit(time)

## Something that effects constantly
@abstract
func _effect() -> void;

## Something that effects at the start, only used in [code]StatusEffect.Conditionals.START_END_DIFF[/code]
@abstract
func _start_effect() -> void;

## Something that effects at the end, only used in [code]StatusEffect.Conditionals.START_END_DIFF[/code]
@abstract
func _end_effect() -> void;
