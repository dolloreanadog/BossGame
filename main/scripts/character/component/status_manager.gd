@icon("uid://bmpghfb1tyte5")
extends Timer
## Manages and stores status effects
class_name StatusManager

# WARNING: I just realized we're using rpc for resources,

# TODO: https://docs.godotengine.org/en/stable/classes/class_multiplayerspawner.html
# TODO: So far, the multiplayer authority would be the current player?
# TODO: After some testing, decide whether to get host to override this authority

var character: Character = get_parent()
var _is_iterating: bool = false

var buffs: Array[BuffEffect]
var debuffs: Array[DebuffEffect]

## How many buffs a character can have
@export var buff_limit: int
## How many debuffs a character can have
@export var debuff_limit: int

func should_iterate() -> void:
	if !multiplayer.is_server(): return
	for i: int in randi_range(0, 50):
		if !_is_iterating:
			_iterate.rpc()
			break
		await get_tree().create_timer(0.01).timeout

@rpc("authority", "call_local", "reliable")
func _iterate() -> void:
	_is_iterating = true
	# TODO: Make sure this doesn't cause a memory leak
	var new_buffs: Array[BuffEffect]
	var new_debuffs: Array[DebuffEffect]
	
	for buff: BuffEffect in buffs:
		buff.activate()
		if buff.time > 0:
			new_buffs.push_back(buff)
		#print(buff.get_reference_count())
	
	for debuff: DebuffEffect in debuffs:
		debuff.activate()
		if debuff.time > 0:
			new_debuffs.push_back(debuff)
		#print(debuff.get_reference_count())
	
	# this should remove dead buffs.
	buffs = new_buffs
	debuffs = new_debuffs
	_is_iterating = false

## @experimental: Will only add if necessary to ensure authority will have authority over this
@rpc("authority", "call_local", "reliable")
func server_add_buff(buff: BuffEffect) -> void:
	if !multiplayer.is_server():
		add_buff.rpc(buff)

## @experimental: Will only add if necessary to ensure authority will have authority over this
@rpc("authority", "call_local", "reliable")
func server_add_debuff(debuff: DebuffEffect) -> void:
	if !multiplayer.is_server():
		add_debuff.rpc(debuff)

## When you use this, you must do something like Fire.new()
@rpc("any_peer", "call_local", "reliable")
func add_buff(buff: DebuffEffect) -> void:
	if buffs.size() > buff_limit: return
	# Hopefully makes this local as well
	#var status_resource: BuffEffect = Global.GLOBAL_STATUS_INDEX.grab_status_resource(buff)
	# This should be able to find the same resource
	var found: int = buffs.find(buff)
	if found == -1:
		buff.character = character
		buffs.push_back(buff)
	else:
		if buffs[found].stacks < buff.max_stacks:
			buffs[found].stacks += 1
			buffs[found].time = buff.time
	
	#if buffs.has(buff):

## When you use this, you must do something like Fire.new()
@rpc("any_peer", "call_local", "reliable")
func add_debuff(debuff: DebuffEffect) -> void:
	if debuffs.size() > debuff_limit: return
	# Hopefully makes this local as well
	#var status_resource: BuffEffect = Global.GLOBAL_STATUS_INDEX.grab_status_resource(debuff)
	# This should be able to find the same resource
	var found: int = debuffs.find(debuff)
	if found == -1:
		debuff.character = character
		debuffs.push_back(debuff)
	else:
		if debuffs[found].stacks < debuff.max_stacks:
			debuffs[found].stacks += 1
			debuffs[found].time = debuff.time

func _on_timeout() -> void:
	should_iterate()
