extends CharacterComponent
class_name WeaponManager

# INFO: Just letting you know, might need to scale either 1000x or something to fix it dissapearing

@onready var weapon_slot_1: Node3D = %WeaponSlot1
@onready var weapon_slot_2: Node3D = %WeaponSlot2

var weapon1: Weapon
var weapon2: Weapon

func equip(slot: int, weapon_id: int):
	if slot == 1:
		pass
	elif slot == 2:
		pass
	else:
		push_error("This is not a valid slot, putting it in slot 1")
