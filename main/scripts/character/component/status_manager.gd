extends CharacterComponent
class_name StatusManager

var buffs: Array[BuffEffect]
var debuffs: Array[DebuffEffect]


func add_buff(buff: BuffEffect) -> void:
	buff.character = character
	buffs.push_back(buff)


func add_debuff() -> void:
	pass
