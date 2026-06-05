extends PlayerComponent
class_name WeaponManager

# INFO: Just letting you know, might need to scale either 1000x or something to fix it dissapearing

# TODO: We're following this https://www.youtube.com/watch?v=SB0QrnI_-IQ

@onready var world_weapon_slot_1: Node3D = %WeaponSlot1
@onready var world_weapon_slot_2: Node3D = %WeaponSlot2
# INFO: Handle view model weapons
@onready var view_weapon_slot_1: Node3D = %Weapon1
var view_weapon_1_animation: AnimationPlayer
@onready var view_weapon_slot_2: Node3D = %Weapon2
var view_weapon_2_animation: AnimationPlayer
## This is used when a weapon is put into the backpack
@onready var back_pack_reload_timer: Timer = $BackPackReloadTimer


@export var is_holding_primary: bool = true:
	set(value):
		is_holding_primary = value
		_switch_weapon(value)
@export var is_reloading: bool = false

@export var weapon_1: Weapon
@export var weapon_2: Weapon

## @deprecated: It seems that ammo changed does it as well as this for some reason
signal weapon_switch(new_ammo: int, new_max_ammo: int)
signal ammo_changed(new_ammo: int)

func _ready() -> void:
	equip(1, weapon_1)
	equip(2, weapon_2)
	await get_tree().create_timer(0.5).timeout
	weapon_1.reset_stats()
	weapon_2.reset_stats()
	
	is_holding_primary = true
	ammo_changed.emit(weapon_1.current_ammo)
	
	if is_multiplayer_authority():
		player.world_model.hide()

func _switch_weapon(primary: bool) -> void:
	_switch_view_weapon(primary)
	_switch_world_weapon.rpc(primary)
	if primary:
		print("weapon 1: %s" % weapon_2.current_ammo)
		weapon_switch.emit(weapon_1.current_ammo, weapon_1.max_ammo)
	else:
		print("weapon 2: %s" % weapon_2.current_ammo)
		weapon_switch.emit(weapon_2.current_ammo, weapon_2.max_ammo)

@rpc("any_peer", "call_local", "reliable")
func _switch_world_weapon(primary: bool) -> void:
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
	_view_hold(primary, false)

	# TODO: It should also set world animation

func _switch_view_weapon(primary: bool) -> void:
	if is_multiplayer_authority():
		if primary:
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
		view_weapon_1_animation = view_weapon_slot_1.get_child(0).get_node("AnimationPlayer")
	elif slot == 2:
		weapon = weapon_2.view_mesh.instantiate()
		view_weapon_slot_2.add_child(weapon)
		weapon.position = weapon_2.view_position
		weapon.rotation_degrees = weapon_2.view_rotation
		view_weapon_2_animation = view_weapon_slot_2.get_child(0).get_node("AnimationPlayer")

func unload_weapon(slot: int) -> void:
	var selected_weapon: MeshInstance3D
	if slot == 1:
		if world_weapon_slot_1.get_child_count() > 0:
			selected_weapon = world_weapon_slot_1.get_child(0)
			selected_weapon.queue_free()
			view_weapon_1_animation = null
	elif slot == 2:
		if world_weapon_slot_2.get_child_count() > 0:
			selected_weapon = world_weapon_slot_2.get_child(0)
			selected_weapon.queue_free()
			view_weapon_2_animation = null
	else:
		push_error("This is not a valid slot")

func _on_player_fire_1() -> void:
	_handle_fire_1.rpc()


@rpc("any_peer", "call_local", "reliable")
func _handle_fire_1() -> void: ## TODO: We can probably reorganize this better
	if is_reloading: return
	if multiplayer.is_server() || is_multiplayer_authority():
		if !player.health.is_dead:
			var collider: CollisionShape3D
			if player.weapon_raycast.get_collider() is CollisionShape3D:
				collider = player.weapon_raycast.get_collider()
			if is_holding_primary:
				if weapon_1.can_shoot():
					weapon_1.do_shoot_script_1()
					if collider is EnemyCollider:
						(collider as EnemyCollider).Hit.emit(weapon_1.current_damage)
					weapon_1.current_ammo -= 1
					ammo_changed.emit(weapon_1.current_ammo)
					print("Speak")
			else:
				if weapon_2.can_shoot():
					weapon_2.do_shoot_script_2()
					if collider is EnemyCollider:
						(collider as EnemyCollider).Hit.emit(weapon_1.current_damage)
					weapon_2.current_ammo -= 1
					ammo_changed.emit(weapon_2.current_ammo)
					print("Speak")
	
	if is_multiplayer_authority():
		# View Model Animation
		if _check_holding_has_ammo():
			_view_shoot_1(is_holding_primary)
	else:
		# World Model Animation
		pass


func _on_player_fire_2() -> void:
	_handle_fire_2.rpc()


@rpc("any_peer", "call_local", "reliable")
func _handle_fire_2() -> void:
	if multiplayer.is_server():
		if !player.health.is_dead:
			var collider: CollisionShape3D
			if player.weapon_raycast.get_collider() is CollisionShape3D:
				collider = player.weapon_raycast.get_collider()
			if is_holding_primary:
				if weapon_1.can_shoot():
					weapon_1.do_shoot_script_1()
					if collider is EnemyCollider:
						(collider as EnemyCollider).Hit.emit(weapon_1.current_damage)
					weapon_1.current_ammo -= weapon_1.secondary_ammo
					ammo_changed.emit(weapon_1.current_ammo)
					print("Speak")
			else:
				if weapon_2.can_shoot():
					weapon_2.do_shoot_script_2()
					if collider is EnemyCollider:
						(collider as EnemyCollider).Hit.emit(weapon_1.current_damage)
					weapon_2.current_ammo -= weapon_2.secondary_ammo
					ammo_changed.emit(weapon_2.current_ammo)
					print("Speak")
	
	if is_multiplayer_authority():
		# View Model Animation
		if _check_holding_has_ammo():
			_view_shoot_2(is_holding_primary)
	else:
		# World Model Animation
		pass


func _on_player_reload() -> void:
	_handle_reload.rpc()
	_view_reload(is_holding_primary)

## This will reload the currently held gun, it also does backpack reloading as this method can run in the background
@rpc("any_peer", "call_local", "reliable")
func _handle_reload() -> void:
	if is_holding_primary:
		if !weapon_1.is_reloading:
			player.world_animation_tree.play_reload_animation() # TODO: We need to be able to set the animation speed
			weapon_1.is_reloading = true
			await get_tree().create_timer(weapon_1.current_reload_time).timeout
			weapon_1.current_ammo = weapon_1.max_ammo
			# This is fine because this does something all visual and not gameplay
			if !view_weapon_slot_2.visible:
				ammo_changed.emit(weapon_1.current_ammo)
			weapon_1.is_reloading = false
	else:
		if !weapon_2.is_reloading:
			player.world_animation_tree.play_reload_animation()
			weapon_2.is_reloading = true
			await get_tree().create_timer(weapon_2.current_reload_time).timeout
			weapon_2.current_ammo = weapon_2.max_ammo
			if !view_weapon_slot_1.visible:
				ammo_changed.emit(weapon_2.current_ammo)
			weapon_2.is_reloading = false

func _on_player_weapon_ability_used() -> void:
	_handle_weapon_ability.rpc()

@rpc("any_peer", "call_local", "reliable")
func _handle_weapon_ability() -> void:
	_view_use(is_holding_primary)

func _on_player_weapon_switch() -> void:
	if is_holding_primary:
		is_holding_primary = false
	else:
		is_holding_primary = true

func _check_holding_has_ammo() -> bool:
	if is_holding_primary:
		return weapon_1.can_shoot()
	else:
		return weapon_2.can_shoot()

#region View Model Animations
# view_weapon_1_animation, view_weapon_2_animation
func _view_shoot_1(primary: bool) -> void:
	if primary:
		view_weapon_1_animation.play("shoot")
	else:
		view_weapon_2_animation.play("shoot")
	_view_hold(primary)

func _view_shoot_2(primary: bool) -> void:
	if primary:
		view_weapon_1_animation.play("shoot2")
	else:
		view_weapon_2_animation.play("shoot2")
	_view_hold(primary)

func _view_reload(primary: bool) -> void:
	if primary:
		view_weapon_1_animation.play("reload")
	else:
		view_weapon_2_animation.play("reload")
	_view_hold(primary)

func _view_use(primary: bool) -> void:
	if primary:
		view_weapon_1_animation.play("extra1")
	else:
		view_weapon_2_animation.play("extra1")
	_view_hold(primary)

## It play the looping hold animation for the weapon, queue will queue the animation
func _view_hold(primary: bool, queue: bool = true) -> void:
	if queue:
		if primary:
			view_weapon_1_animation.queue("hold")
		else:
			view_weapon_2_animation.queue("hold")
	else:
		if primary:
			view_weapon_1_animation.play("hold")
		else:
			view_weapon_2_animation.play("hold")
#endregion
