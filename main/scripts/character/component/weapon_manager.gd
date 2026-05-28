extends CharacterComponent
class_name WeaponManager

# INFO: Just letting you know, might need to scale either 1000x or something to fix it dissapearing

# TODO: We're following this https://www.youtube.com/watch?v=SB0QrnI_-IQ

@onready var world_weapon_slot_1: Node3D = %WeaponSlot1
@onready var world_weapon_slot_2: Node3D = %WeaponSlot2
# INFO: Handle view model weapons
@onready var view_weapon_slot_1: Node3D = %Weapon1
@onready var view_weapon_slot_2: Node3D = %Weapon2

var _is_holding_primary: bool = true

var weapon_1: Weapon
var weapon_2: Weapon

func _switch_weapon(primary: bool) -> void:
	_switch_view_weapon(primary)
	_switch_world_weapon.rpc(primary)


@rpc("any_peer", "call_local", "reliable")
func _switch_world_weapon(primary: bool) -> void:
	if !is_multiplayer_authority():
		if _is_holding_primary == primary:
			pass
		else:
			pass
	# TODO: It should also set world animation

func _switch_view_weapon(primary: bool) -> void:
	if is_multiplayer_authority():
		if _is_holding_primary == primary:
			view_weapon_slot_1.show()
			view_weapon_slot_2.hide()
		else:
			view_weapon_slot_1.hide()
			view_weapon_slot_2.show()

func equip(slot: int, weapon: Weapon):
	weapon.resource_local_to_scene = true
	if slot == 1:
		_load_world_weapon()
		_load_view_weapon()
		weapon_1 = weapon
		# We're only doing this in order to not create another character variable, we're also not using this for enemies
		(character as PlayerCharacter).Fire1.connect(weapon_1.fire1) # Oh shit, we shouldn't use resource for firing
	elif slot == 2:
		_load_world_weapon()
		_load_view_weapon()
		weapon_2 = weapon
	else:
		push_error("This is not a valid slot, putting it in slot 1")

@rpc("any_peer", "call_local", "reliable")
func _load_world_weapon() -> void:
	if !is_multiplayer_authority():
		pass
	# TODO: It should also set world animation

func _load_view_weapon() -> void:
	if is_multiplayer_authority():
		pass

func unload_weapon(slot: int) -> void:
	var selected_weapon: MeshInstance3D
	if slot == 1:
		selected_weapon = world_weapon_slot_1.get_child(0)
		selected_weapon.queue_free()
	elif slot == 2:
		selected_weapon = world_weapon_slot_2.get_child(0)
		selected_weapon.queue_free()
	else:
		push_error("This is not a valid slot")
