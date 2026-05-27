extends CharacterComponent
class_name WeaponManager

# INFO: Just letting you know, might need to scale either 1000x or something to fix it dissapearing

@onready var weapon_slot_1: Node3D = %WeaponSlot1
@onready var weapon_slot_2: Node3D = %WeaponSlot2

var weapon1: Weapon
var weapon2: Weapon

func equip(slot: int, weapon_id: Weapon):
	if slot == 1:
		load_weapon()
	elif slot == 2:
		load_weapon()
	else:
		push_error("This is not a valid slot, putting it in slot 1")

func load_weapon() -> void:
	
	pass

func unload_weapon(slot: int) -> void:
	var selected_weapon: MeshInstance3D
	if slot == 1:
		selected_weapon = weapon_slot_1.get_child(0)
		selected_weapon.queue_free()
	elif slot == 2:
		selected_weapon = weapon_slot_2.get_child(0)
		selected_weapon.queue_free()
	else:
		push_error("This is not a valid slot")
