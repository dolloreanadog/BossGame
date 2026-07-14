@icon("uid://bmpghfb1tyte5")
extends Timer
class_name StatusManager

@onready var character: Character = get_parent()
@export var player: PlayerCharacter

signal effects_updated(active_effects: Dictionary)

## Store id & State [br]
## It should look like this {"fire": {"duration": 5, "stacks": 5}}
var active_effects: Dictionary[String, Dictionary]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timeout.connect(_on_timeout)


#region Server
func _iterate() -> void:
	if not multiplayer.is_server(): return
	
	if !active_effects.is_empty():
		print("Active Effect Size: %s" % active_effects.size())
	
	for effect_id: String in active_effects.keys():
		var state: Dictionary = active_effects[effect_id]
		state["duration"] -= 1
		
		var resource: StatusEffect = Global.global_status_index.get_effect(effect_id)
		if is_instance_valid(resource):
			if is_instance_valid(player):
				resource.server_time_effect(character, state["stacks"], player)
			else:
				resource.server_time_effect(character, state["stacks"])
		
		if state["duration"] <= 0:
			active_effects.erase(effect_id)
			
			if is_instance_valid(resource):
				if is_instance_valid(player):
					resource.server_remove_effect(character, state["stacks"], player)
				else:
					resource.server_remove_effect(character, state["stacks"])
				client_remove_effect.rpc(effect_id)
	
	effects_updated.emit(active_effects) # This should update the effect UI, but it ain't

## If you want to remove a stack, it is not within the plans. Remove it first then add the status effect with the amount of stacks
func apply_effect(effect_id: String, stacks: float) -> void:
	if not multiplayer.is_server(): return
	
	var resource: StatusEffect = Global.global_status_index.get_effect(effect_id)
	
	if active_effects.has(effect_id):
		active_effects[effect_id].duration = resource.duration # Might want to look into not obfuscating this
		active_effects[effect_id].stacks = mini(active_effects[effect_id].stacks + stacks, Global.global_status_index.get_effect(effect_id).max_stacks)
	else:
		active_effects[effect_id] = {"duration": resource.duration, "stacks": stacks}
	
	if is_instance_valid(player):
		resource.server_apply_effect(character, active_effects[effect_id].stacks, player)
	else:
		resource.server_(character, active_effects[effect_id].stacks)
	
	effects_updated.emit(active_effects)
	
	# Get clients to sync to this
	client_add_effect.rpc(effect_id, active_effects[effect_id].duration, active_effects[effect_id].stacks)
#endregion

#region Client
## Syncs clients effect with server effects
@rpc("authority", "call_local", "reliable")
func client_add_effect(effect_id: String, duration: float, stacks: int) -> void:
	if not active_effects.has(effect_id):
		active_effects[effect_id] = {}
	
	# Client only need the visuals
	active_effects[effect_id].duration = duration
	active_effects[effect_id].stacks = stacks
	
	#var resource: NewStatusEffect = Global.global_status_index.get_effect(effect_id)
	# We can then do particle stuff here
	
	effects_updated.emit(active_effects)

## Syncs clients effect with server effects
@rpc("authority", "call_local", "reliable")
func client_remove_effect(effect_id: String) -> void:
	active_effects.erase(effect_id)
	effects_updated.emit(active_effects)

# The reason why these client has Authority instead of of any_peer
# With authority & call_local combined makes it so the method is only called on the their own.
# So the server can call it and it would be sent to all peers
#endregion

func _on_timeout() -> void:
	if multiplayer.is_server():
		_iterate()
