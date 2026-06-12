extends MultiplayerSpawner
class_name StatusManager

# TODO: https://docs.godotengine.org/en/stable/classes/class_multiplayerspawner.html
# TODO: So far, the multiplayer authority would be the current player?
# TODO: After some testing, decide whether to get host to override this authority

var character: Character = get_parent()

var buffs: Array[BuffEffect]
var debuffs: Array[DebuffEffect]

signal buff_finished(effect: BuffEffect)
## For every second, it should emit
signal buff_activated(effect: BuffEffect)
signal buff_added(effect: BuffEffect)
signal debuff_finished(effect: BuffEffect)
## For every second, it should emit
signal debuff_activated(effect: BuffEffect)
signal debuff_added(effect: BuffEffect)

func add_buff(buff: BuffEffect) -> void:
	buff.character = character
	buffs.push_back(buff)


func add_debuff() -> void:
	pass
