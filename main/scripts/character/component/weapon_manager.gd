extends PlayerComponent
class_name WeaponManager

# INFO: Just letting you know, might need to scale either 1000x or something to fix it dissapearing

# TODO: We're following this https://www.youtube.com/watch?v=SB0QrnI_-IQ

@onready var world_weapon_slot_1: Node3D = %WeaponSlot1
@onready var world_weapon_slot_2: Node3D = %WeaponSlot2
# INFO: Handle view model weapons
@onready var view_weapon_slot_1: Node3D = %Weapon1
@onready var view_weapon_slot_2: Node3D = %Weapon2

@export var is_holding_primary: bool = true:
	set(value):
		is_holding_primary = value
		_switch_weapon(value)

@export var weapon_1: Weapon
@export var weapon_2: Weapon

func _ready() -> void:
	equip(1, weapon_1)
	equip(2, weapon_2)
	await get_tree().create_timer(0.5).timeout
	is_holding_primary = true

func _switch_weapon(primary: bool) -> void:
	_switch_view_weapon(primary)
	_switch_world_weapon.rpc(primary)

@rpc("any_peer", "call_local", "reliable")
func _switch_world_weapon(primary: bool) -> void:
	print("Switching weapon")
	#if !is_multiplayer_authority():
	if primary:
		player.world_animation_tree.equipped = weapon_1.type + 1
		world_weapon_slot_1.show()
		world_weapon_slot_2.hide()
		player.weapon_raycast.target_position.z = weapon_1.raycast_range
	else:
		player.world_animation_tree.equipped = weapon_2.type + 1
		world_weapon_slot_1.hide()
		world_weapon_slot_2.show()
		player.weapon_raycast.target_position.z = weapon_2.raycast_range

	# TODO: It should also set world animation

func _switch_view_weapon(primary: bool) -> void:
	if is_multiplayer_authority():
		if is_holding_primary == primary:
			view_weapon_slot_1.show()
			view_weapon_slot_2.hide()
		else:
			view_weapon_slot_1.hide()
			view_weapon_slot_2.show()

func equip(slot: int, weapon: Weapon):
	weapon.resource_local_to_scene = true
	unload_weapon(slot)
	if slot == 1:
		weapon_1 = weapon
		_load_world_weapon(slot)
		_load_view_weapon(slot)
		
	elif slot == 2:
		weapon_2 = weapon
		_load_world_weapon(slot)
		_load_view_weapon(slot)
	else:
		push_error("This is not a valid slot, putting it in slot 1")

@rpc("any_peer", "call_local", "reliable")
func _load_world_weapon(slot: int) -> void:
	var weapon: Node3D
	#if !is_multiplayer_authority():
		#pass
	if slot == 1:
		weapon = weapon_1.world_mesh.instantiate()
		world_weapon_slot_1.add_child(weapon)
		print("Previous rotation: %s" % [weapon.rotation])
		
		weapon.position = weapon_1.world_position
		weapon.rotation_degrees = weapon_1.world_rotation
		print("New rotation: %s" % [weapon.rotation])
	elif slot == 2:
		weapon = weapon_2.world_mesh.instantiate()
		world_weapon_slot_2.add_child(weapon)
		weapon.position = weapon_2.world_position
		weapon.rotation_degrees = weapon_2.world_rotation
	# TODO: It should also set world animation

func _load_view_weapon(slot: int) -> void:
	var weapon: Node3D
	#if is_multiplayer_authority():
		#pass
	if slot == 1:
		weapon = weapon_1.view_mesh.instantiate()
		view_weapon_slot_1.add_child(weapon)
		weapon.position = weapon_1.view_position
		weapon.rotation_degrees = weapon_1.view_rotation
	elif slot == 2:
		weapon = weapon_2.view_mesh.instantiate()
		view_weapon_slot_2.add_child(weapon)
		weapon.position = weapon_2.view_position
		weapon.rotation_degrees = weapon_2.view_rotation

func unload_weapon(slot: int) -> void:
	var selected_weapon: MeshInstance3D
	if slot == 1:
		if world_weapon_slot_1.get_child_count() > 0:
			selected_weapon = world_weapon_slot_1.get_child(0)
			selected_weapon.queue_free()
	elif slot == 2:
		if world_weapon_slot_2.get_child_count() > 0:
			selected_weapon = world_weapon_slot_2.get_child(0)
			selected_weapon.queue_free()
	else:
		push_error("This is not a valid slot")

func _on_player_fire_1() -> void:
	_handle_fire_1.rpc()


@rpc("any_peer", "call_local", "reliable")
func _handle_fire_1() -> void:
	if multiplayer.is_server():
		if player.weapon_raycast.get_collider() is CollisionShape3D:
			var collider: CollisionShape3D = player.weapon_raycast.get_collider()
			if is_holding_primary:
				weapon_1.do_shoot_script_1()
				if collider is EnemyCollider:
					(collider as EnemyCollider).Hit.emit(weapon_1.current_damage)
					weapon_1.current_ammo -= 1
			else:
				weapon_2.do_shoot_script_2()
				if collider is EnemyCollider:
					(collider as EnemyCollider).Hit.emit(weapon_1.current_damage)
				weapon_2.current_ammo -= 1
	
	if is_multiplayer_authority():
		# View Model Animation
		pass
	else:
		# World Model Animation
		pass


func _on_player_fire_2() -> void:
	_handle_fire_2.rpc()


@rpc("any_peer", "call_local", "reliable")
func _handle_fire_2() -> void:
	if multiplayer.is_server():
		var collider: CollisionShape3D = player.weapon_raycast.get_collider()
		if is_holding_primary:
			weapon_1.do_shoot_script_1()
			if collider is EnemyCollider:
				(collider as EnemyCollider).Hit.emit(weapon_1.current_damage)
				weapon_1.current_ammo -= weapon_1._secondary_ammo
		else:
			weapon_2.do_shoot_script_2()
			if collider is EnemyCollider:
				(collider as EnemyCollider).Hit.emit(weapon_1.current_damage)
				weapon_2.current_ammo -= weapon_2._secondary_ammo
		
	if is_multiplayer_authority():
		# View Model Animation
		pass
	else:
		# World Model Animation
		pass
	

func _on_player_reload() -> void:
	pass # Replace with function body.

@rpc("any_peer", "call_local", "reliable")
func _handle_reload() -> void:
	pass

func _on_player_weapon_ability_used() -> void:
	pass # Replace with function body.

@rpc("any_peer", "call_local", "reliable")
func _handle_weapon_ability() -> void:
	pass

func _on_player_weapon_switch() -> void:
	print("Print Pressed")
	if is_holding_primary:
		is_holding_primary = false
	else:
		is_holding_primary = true

@rpc("any_peer", "call_local", "reliable")
func _back_pack_reload() -> void:
	pass

#region 1st Weapon Iteration
#func shoot_primary(is_alt_fire: bool) -> void:
	#if !is_multiplayer_authority(): return
	#if !is_holding_primary: return
	#
	## TODO: Do view model shoot
#
#func shoot_secondary(is_alt_fire: bool) -> void:
	#if !is_multiplayer_authority(): return
	#if is_holding_primary: return
	#
	## TODO: Do view model shoot
#
#
#func reload() -> void:
	#if !is_multiplayer_authority(): return
	#
	## TODO: Do view model reload
	#_server_reload.rpc()
#
#@rpc("any_peer", "call_local", "reliable")
#func _server_reload() -> void:
	#if multiplayer.is_server():
		#if is_holding_primary: 
			#weapon_1.current_ammo = weapon_1._ammo
		#else:
			#weapon_1.current_ammo = weapon_1._ammo
	#
	#if !is_multiplayer_authority():
		## Do reload world animation
		#pass
#
#@rpc("any_peer", "call_local", "reliable")
#func _client_reload() -> void:
	#if !is_multiplayer_authority(): return
	#
#
#@rpc("any_peer", "call_local", "reliable")
#func server_shoot_primary(is_alt_fire: bool):
	#if multiplayer.is_server():
		#if !is_alt_fire:
			## Check if they have ammo
			## Check if the raycast hit the boss and do damage
			## Remove ammo
			## Then we rpc back the weapon effect
			#pass
		#else:
			## Check if they have ammo
			## Check if the raycast hit the boss and do damage
			## Remove ammo
			## Do Weapon Effect
			#pass
	#if !is_multiplayer_authority():
		#if !is_alt_fire:
			## World Model Animation
			#pass
		#else:
			## World Model Animation
			#pass
		#pass
#
#@rpc("any_peer", "call_local", "reliable")
#func server_shoot_secondary(is_alt_fire: bool):
	#if multiplayer.is_server():
		#if !is_alt_fire:
			## Check if they have ammo
			## Check if the raycast hit the boss and do damage
			## Remove ammo
			## Do Weapon Effect
			#pass
		#else:
			## Check if they have ammo
			## Check if the raycast hit the boss and do damage
			## Remove ammo
			## Do Weapon Effect
			#pass
	#if !is_multiplayer_authority():
		#if !is_alt_fire:
			## World Model Animation
			#pass
		#else:
			## World Model Animation
			#pass
		#pass
#endregion
