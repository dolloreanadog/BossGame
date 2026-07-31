@icon("uid://dgd73cpjtpfaa")
extends PlayerComponent
## Handles weapons for the player [br]
## id in server is meant so it can send only to the authority
class_name NewWeaponManager

#region Visuals
#region World Weapon Slots
@onready var world_weapon_slot_1: Node3D = %WeaponSlot1
@onready var world_weapon_slot_2: Node3D = %WeaponSlot2
#endregion

#region View Weapon Slots
@onready var view_weapon_slot_1: Node3D = %Weapon1
var view_weapon_1_animation: AnimationPlayer
@onready var view_weapon_slot_2: Node3D = %Weapon2
var view_weapon_2_animation: AnimationPlayer
#endregion
#endregion

enum Movement {IDLE, SHOOTING, RELOADING}
var current_move_state: Movement = Movement.IDLE

## The reason for this is because, since we cannot use resources over network [br]
## If we for some reason want more than three weapons, move to enums
@export var is_holding_primary: bool = true: 
	set(value):
		is_holding_primary = value
		#_switch_weapon(value)
		#current_weapon = get_current_weapon()
		#change_speed_state(Movement.IDLE)
@export var primary_weapon: NewWeapon
@export var secondary_weapon: NewWeapon

## How long the player is slowed when you shoot the gun
@export var shoot_slow_length: float = 0.05

var current_weapon: NewWeapon

signal weapon_switch(new_ammo: int, new_max_ammo: int)
signal ammo_changed(new_ammo: int)

#region Misc
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# hide world model
	player._show_view_model()
	# equip weapons
	equip(1, primary_weapon)
	equip(2, secondary_weapon)
	
	SteamServer
	
	primary_weapon.can_all_fire = false
	secondary_weapon.can_all_fire = false
	
	await get_tree().create_timer(0.5).timeout # a bit of a timeout, to prevent lock out
	
	primary_weapon.reset_stats()
	secondary_weapon.reset_stats()
	
	primary_weapon.can_all_fire = true
	secondary_weapon.can_all_fire = true
	
	player._show_view_model()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Loads the weapon for the player
func equip(slot: int, weapon: NewWeapon) -> void:
	_unload_weapon.rpc(slot)
	if slot == 1:
		primary_weapon = weapon
		_load_world_weapon.rpc(slot)
		_load_view_weapon(slot)
	elif slot == 2:
		secondary_weapon = weapon
		_load_world_weapon.rpc(slot)
		_load_view_weapon(slot)
	else:
		push_error("This is not a valid slot, putting it in slot 1")


func get_state_speed(state: Movement, is_alt_fire: bool = false) -> float:
	match state:
		Movement.IDLE:
			return current_weapon.move_speed
		Movement.SHOOTING:
			if is_alt_fire:
				return current_weapon.shoot_slow_1
			else:
				return current_weapon.shoot_slow_2
		Movement.RELOADING:
			return current_weapon.reload_slow
		_:
			push_warning("get_state_speed: Not a valid move state")
			return player.move_speed

## Grabs the collider shape. Just so we can check if it is a weak point or not. [br]
## Probably only used by server
func _get_enemy_collider(collider: Object , shape_index: int) -> EnemyCollider:
	if not collider is EnemyCharacter: return null
	var shape: Object = collider.shape_owner_get_owner(shape_index)
	return shape

func _place_decal(normal: Vector3, position: Vector3) -> void:
	if not is_instance_valid(Global.decal_container): return
	# Do a setting to check if they want weapon decals
	var bullet_decal: BulletDecal
	
	bullet_decal = current_weapon.bullet_decal.instantiate()
	Global.decal_container.add_child(bullet_decal)
	bullet_decal.global_position = position
	bullet_decal.look_at(bullet_decal.global_position + normal, Vector3.UP + Vector3(0.001, 0, 0)) # We're adding this little offset so we don't get the error
	bullet_decal.rotate_object_local(Vector3.RIGHT, -PI/2)

func _play_tracer(start: Vector3, end: Vector3) -> void:
	pass

@rpc("any_peer", "call_local", "reliable")
func _unload_weapon(slot: int) -> void:
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
#endregion

# Only Server runs these, all calculations down here, then we send to clients
#region Server
## This handles how fast the character should be depending on weapon a state [br]
## Not on server, as server & player only needs to track position. [br]
## Maybe we can have a bit of server validation to check if good [br]
## This needs no rpc, as it should be called by other server methods
func _server_change_speed_state(id: int, state: Movement, is_alt_fire: bool = false) -> void:
	if not is_instance_valid(current_weapon): return # So we don't do this when there is no weapon
	current_move_state = state
	
	var new_speed: float = 0
	match state:
		Movement.IDLE:
			new_speed = current_weapon.move_speed * player.movement_multiplier 
		Movement.SHOOTING:
			if is_alt_fire:
				new_speed = current_weapon.shoot_slow_1 * player.movement_multiplier 
				await get_tree().create_timer(current_weapon.shoot_slow_duration_1).timeout
				if not current_move_state == Movement.RELOADING: # So we don't mess up reload slow
					_server_change_speed_state(id, Movement.IDLE)
			else:
				new_speed = current_weapon.shoot_slow_2 * player.movement_multiplier 
				await get_tree().create_timer(current_weapon.shoot_slow_duration_1).timeout
				if not current_move_state == Movement.RELOADING: # So we don't mess up reload slow
					_server_change_speed_state(id, Movement.IDLE)
		Movement.RELOADING:
			player.current_speed = current_weapon.reload_slow * player.movement_multiplier 
	
	_sync_authority_speed_state.rpc_id(id, new_speed)

@rpc("any_peer", "call_local", "reliable")
func _server_fire_rate(id: int, is_alt_fire: bool) -> void:
	current_weapon.is_fire_rate_locked = true
	_authority_sync_fire_rate(true)
	
	if !is_alt_fire:
		await get_tree().create_timer(current_weapon.current_fire_rate_1).timeout
	else:
		await get_tree().create_timer(current_weapon.current_fire_rate_2).timeout
	
	current_weapon.is_fire_rate_locked = false
	_authority_sync_fire_rate(false)

@rpc("any_peer", "call_local", "reliable")
func _server_fire_1(id: int) -> void:
	if multiplayer.is_server():
		if current_weapon.is_reloading: return
		if player.health.is_dead: return
		if not current_weapon.can_shoot(): return
		
		var enemy_collider: EnemyCollider
		
		_server_change_speed_state(id, Movement.SHOOTING)
		
#region Weapon, Pellet, & Damage Calculation
		for pellet: int in current_weapon.pellet_count_1:
			# Calculations and stuff
			var space_state: PhysicsDirectSpaceState3D = player.camera_3d.get_world_3d().direct_space_state
			var from: Vector3 = player.camera_3d.global_position
			
			var accuracy_spread: float = (100 - current_weapon.current_accuracy_1) / 1000
			#print("Accuracy Spread: %s" % accuracy)
			var forward: Vector3 = -player.camera_3d.global_transform.basis.z
			
			var accuracy_x: float = randf_range(-accuracy_spread, accuracy_spread)
			var acccuracy_y: float = randf_range(-accuracy_spread, accuracy_spread)
			var direction: Vector3 = forward + Vector3(accuracy_x, acccuracy_y, 0)
			
			var to: Vector3 = from + direction * -current_weapon.raycast_range
			
			var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to) # We can use from & to for tracer
			
			var result: Dictionary = space_state.intersect_ray(query)
			
			enemy_collider = _get_enemy_collider(result.collider, result.shape)
			
			if enemy_collider is EnemyCollider:
				enemy_collider.Hit.emit(current_weapon.get_primary_damage(), current_weapon.current_weak_point_mult)
			
			_client_sync_fire_1.rpc()
			# result is for decals | 
			_authority_sync_fire_1.rpc(result.normal, result.position, current_weapon.current_ammo)
#endregion
		current_weapon.shoot_1()
		current_weapon.current_ammo -= current_weapon.current_ammo_consumption_1
			
		_server_fire_rate(id, false) # Does need rpc


@rpc("any_peer", "call_local", "reliable")
func _server_fire_2(id: int) -> void:
	if multiplayer.is_server():
		if current_weapon.is_reloading: return
		if player.health.is_dead: return
		if not current_weapon.can_shoot(): return
		
		var enemy_collider: EnemyCollider
		
		_server_change_speed_state(id, Movement.SHOOTING)
		
#region Weapon, Pellet, & Damage Calculation
		for pellet: int in current_weapon.pellet_count_2:
			# Calculations and stuff
			var space_state: PhysicsDirectSpaceState3D = player.camera_3d.get_world_3d().direct_space_state
			var from: Vector3 = player.camera_3d.global_position
			
			var accuracy_spread: float = (100 - current_weapon.current_accuracy_2) / 1000
			#print("Accuracy Spread: %s" % accuracy)
			var forward: Vector3 = -player.camera_3d.global_transform.basis.z
			
			var accuracy_x: float = randf_range(-accuracy_spread, accuracy_spread)
			var acccuracy_y: float = randf_range(-accuracy_spread, accuracy_spread)
			var direction: Vector3 = forward + Vector3(accuracy_x, acccuracy_y, 0)
			
			var to: Vector3 = from + direction * -current_weapon.raycast_range
			
			var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
			
			var result: Dictionary = space_state.intersect_ray(query)
			
			enemy_collider = _get_enemy_collider(result.collider, result.shape)
			
			if enemy_collider is EnemyCollider:
				enemy_collider.Hit.emit(current_weapon.get_primary_damage(), current_weapon.current_weak_point_mult)
			
			_client_sync_fire_2.rpc()
			_authority_sync_fire_2.rpc(result.normal, result.position, current_weapon.current_ammo)
#endregion
		current_weapon.shoot_2()
		current_weapon.current_ammo -= current_weapon.current_ammo_consumption_2
			
		_server_fire_rate(id, true) # Does not need rpc
		
		# result is for decals | 
		

@rpc("any_peer", "call_local", "reliable")
func _server_reload(id: int) -> void:
	if multiplayer.is_server():
		# Calculations and stuff
		if not current_weapon.is_reloading: # So they don't reload during a reload
			current_weapon.reload()
			_server_change_speed_state(id, Movement.RELOADING)
			_client_sync_reload.rpc()
			_authority_sync_reload.rpc_id(id, -1, true)
			await get_tree().create_timer(current_weapon.current_reload_time).timeout
			# Then make idle
			_server_change_speed_state(id, Movement.RELOADING)
			current_weapon.current_ammo = current_weapon.ammo
			_authority_sync_reload.rpc_id(id, current_weapon.current_ammo, false)

@rpc("any_peer", "call_local", "reliable")
func _server_ability_used(id: int) -> void:
	if multiplayer.is_server():
		# Calculations and stuff
		current_weapon.use_ability()
		
		_client_sync_ability_used.rpc()
		_authority_sync_ability_used.rpc_id(id)

## Weapon switch
@rpc("any_peer", "call_local", "reliable")
func _server_switch(id: int) -> void:
	if multiplayer.is_server():
		# Calculations and stuff
		
		# So we need a switch weapon function
		if is_holding_primary:
			is_holding_primary = false
			current_weapon = secondary_weapon
		else:
			is_holding_primary = true
			current_weapon = primary_weapon
		
		
		_client_sync_switch.rpc(is_holding_primary)
		_authority_sync_switch.rpc_id(id, is_holding_primary)
#endregion

# These guys basically just need visualization

# Runs for all other besides authority
#region All Clients
## This loads the world model for all clients besides authority [br]
## TODO: One issue I could see is how does
@rpc("any_peer", "call_remote", "reliable")
func _load_world_weapon(slot: int) -> void:
	if is_multiplayer_authority(): return
	var weapon: Node3D
	
	if slot == 1:
		weapon = primary_weapon.world_mesh.instantiate()
		world_weapon_slot_1.add_child(weapon)
		weapon.position = primary_weapon.world_position
		weapon.rotation_degrees = primary_weapon.world_rotation
		print("New rotation: %s" % [weapon.rotation])
	elif slot == 2:
		weapon = secondary_weapon.world_mesh.instantiate()
		world_weapon_slot_2.add_child(weapon)
		weapon.position = secondary_weapon.world_position
		weapon.rotation_degrees = secondary_weapon.world_rotation
	# TODO: It should also set world animation

@rpc("any_peer", "call_local", "reliable")
func _client_sync_fire_1(...args: Array) -> void: # TODO: Eventually trade out args for actual parameters
	if is_multiplayer_authority(): return
	
	# Play fire sound
	# Do the tracer?
	# Hit effect

@rpc("any_peer", "call_local", "reliable")
func _client_sync_fire_2(...args: Array) -> void: # TODO: Eventually trade out args for actual parameters
	if is_multiplayer_authority(): return
	
	# Play fire sound
	# Do the tracer?
	# Hit effect

@rpc("any_peer", "call_local", "reliable")
func _client_sync_reload(...args: Array) -> void: # TODO: Eventually trade out args for actual parameters
	if is_multiplayer_authority(): return
	
	player.world_animation_tree.play_reload_animation()
	
	# Play reload sound

@rpc("any_peer", "call_local", "reliable")
func _client_sync_ability_used(...args: Array) -> void: # TODO: Eventually trade out args for actual parameters
	if is_multiplayer_authority(): return
	
	# Play ability sound

@rpc("any_peer", "call_local", "reliable")
func _client_sync_switch(is_primary: bool) -> void: # TODO: Eventually trade out args for actual parameters
	if is_multiplayer_authority(): return
	
	
	if is_primary:
		@warning_ignore("int_as_enum_without_cast")
		player.world_animation_tree.equipped = primary_weapon.type + 1
		world_weapon_slot_1.show()
		world_weapon_slot_2.hide()
		player.weapon_raycast.target_position.z = primary_weapon.raycast_range
	else:
		@warning_ignore("int_as_enum_without_cast")
		player.world_animation_tree.equipped = secondary_weapon.type + 1
		world_weapon_slot_1.hide()
		world_weapon_slot_2.show()
		player.weapon_raycast.target_position.z = secondary_weapon.raycast_range
	
	# Play switch sound
#endregion

# Only authority/player can use these
#region Authority
func _get_current_weapon(is_primary: bool) -> NewWeapon:
	var new_current_weapon: NewWeapon
	if is_holding_primary:
		new_current_weapon = primary_weapon
	else:
		new_current_weapon = secondary_weapon
	return new_current_weapon

## This loads the weapon [br]
## Do not worry about seeing both when spawn. Little bit of loading screen magic, it won't be shown.
func _load_view_weapon(slot: int) -> void:
	var weapon: Node3D
	#if is_multiplayer_authority():
		#pass
	if slot == 1:
		weapon = primary_weapon.view_mesh.instantiate()
		view_weapon_slot_1.add_child(weapon)
		weapon.position = primary_weapon.view_position
		weapon.rotation_degrees = primary_weapon.view_rotation
		view_weapon_1_animation = view_weapon_slot_1.get_child(0).get_node("AnimationPlayer")
		_remove_shadow(weapon.get_child(0).get_child(0))
		_view_hold(true)
	elif slot == 2:
		weapon = secondary_weapon.view_mesh.instantiate()
		view_weapon_slot_2.add_child(weapon)
		weapon.position = secondary_weapon.view_position
		weapon.rotation_degrees = secondary_weapon.view_rotation
		view_weapon_2_animation = view_weapon_slot_2.get_child(0).get_node("AnimationPlayer")
		_remove_shadow(weapon.get_child(0).get_child(0))
		_view_hold(false)

## Only used when loading view weapon model
func _remove_shadow(skeleton: Skeleton3D) -> void:
	if is_instance_valid(skeleton):
		for node: Node3D in skeleton.get_children():
			if node is MeshInstance3D:
				node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			else:
				for node2: Node3D in node.get_children():
					node2.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

@rpc("any_peer", "call_local", "reliable")
func _sync_authority_speed_state(speed: float) -> void:
	if not is_multiplayer_authority(): return
	player.current_speed = speed

@rpc("any_peer", "call_local", "reliable")
func _authority_sync_fire_rate(is_alt_fire: bool) -> void:
	if not is_multiplayer_authority(): return
	current_weapon.is_fire_rate_locked = is_alt_fire # Look at server fire rate, server just needs to set this

@rpc("any_peer", "call_local", "reliable")
func _authority_sync_fire_1(normal: Vector3, position: Vector3, ammo: int) -> void: # TODO: Eventually trade out args for actual parameters
	if not is_multiplayer_authority(): return
	current_weapon.current_ammo = ammo
	ammo_changed.emit(current_weapon.current_ammo)
	# Just add some visualization
	
	# recoil
	player.recoil.recoil_fire(current_weapon.current_recoil)
	# view model shoot animation
	_view_shoot_1(is_holding_primary)
	#_play_tracer()
	_place_decal(normal, position)
	
	# Play fire sound

@rpc("any_peer", "call_local", "reliable")
func _authority_sync_fire_2(normal: Vector3, position: Vector3, ammo: int) -> void: # TODO: Eventually trade out args for actual parameters
	if not is_multiplayer_authority(): return
	current_weapon.current_ammo = ammo
	ammo_changed.emit(current_weapon.current_ammo)
	
	player.recoil.recoil_fire(current_weapon.current_recoil)
	# view model shoot animation
	_view_shoot_2(is_holding_primary)
	#_play_tracer()
	_place_decal(normal, position)
	
	# Play fire sound

@rpc("any_peer", "call_local", "reliable")
func _authority_sync_reload(ammo: int, is_reloading: bool) -> void: # TODO: Eventually trade out args for actual parameters
	if not is_multiplayer_authority(): return
	if is_reloading:
		_view_reload(is_holding_primary)
	else:
		ammo_changed.emit(current_weapon.current_ammo)
	
	# Play Reload sound

@rpc("any_peer", "call_local", "reliable")
func _authority_sync_ability_used(...args: Array) -> void: # TODO: Eventually trade out args for actual parameters
	if not is_multiplayer_authority(): return
	_view_ability(is_holding_primary)
	
	# Play ability sound

@rpc("any_peer", "call_local", "reliable")
func _authority_sync_switch(is_primary: bool) -> void: # TODO: Eventually trade out args for actual parameters
	if not is_multiplayer_authority(): return
	
	if is_primary:
		current_weapon = primary_weapon
	else:
		current_weapon = secondary_weapon
	
	weapon_switch.emit(current_weapon.current_ammo, current_weapon.ammo)
	_switch_view_weapon(is_primary)
	
	# Play Switch sound

# Only the authority can see this
#region View Model Animation
## This is for the view model animation [br]
func _view_shoot_1(is_primary: bool) -> void:
	if is_primary:
		view_weapon_1_animation.play("shoot")
	else:
		view_weapon_2_animation.play("shoot")
	_view_hold(is_primary)

## This is for the view model animation [br]
func _view_shoot_2(is_primary: bool) -> void:
	if is_primary:
		view_weapon_1_animation.play("shoot2")
	else:
		view_weapon_2_animation.play("shoot2")
	_view_hold(is_primary)

## This is for the view model animation [br]
func _view_reload(is_primary: bool) -> void:
	if is_primary:
		view_weapon_1_animation.play("reload", -1, current_weapon.reload_animation_speed)
	else:
		view_weapon_2_animation.play("reload", -1, current_weapon.reload_animation_speed)
	_view_hold(is_primary)

## This is for the view model animation [br]
func _view_ability(is_primary: bool) -> void:
	if is_primary:
		view_weapon_1_animation.play("extra1")
	else:
		view_weapon_2_animation.play("extra1")
	_view_hold(is_primary)


## This is for the view model animation [br]
## It play the looping hold animation for the weapon, queue will queue the animation
func _view_hold(is_primary: bool, queue: bool = true) -> void:
	if queue:
		if is_primary:
			view_weapon_1_animation.queue("hold")
		else:
			view_weapon_2_animation.queue("hold")
	else:
		if is_primary:
			view_weapon_1_animation.play("hold")
		else:
			view_weapon_2_animation.play("hold")

func _switch_view_weapon(is_primary: bool) -> void:
	if is_primary:
		view_weapon_slot_1.show()
		view_weapon_slot_2.hide()
	else:
		view_weapon_slot_1.hide()
		view_weapon_slot_2.show()
#endregion
#endregion

#region Signal Events
## A Signal Event
func _on_player_fire_1() -> void:
	# client <- Server (origin) -> authority
	# Do rpc_id() the server, I think it's 1
	_server_fire_1.rpc_id(1, player.player_id)


func _on_player_fire_2() -> void:
	# client <- Server (origin) -> authority
	_server_fire_2.rpc_id(1, player.player_id)


func _on_reload() -> void:
	# client <- Server (origin) -> authority
	_server_reload.rpc_id(1, player.player_id)


func _weapon_ability_used() -> void:
	# client <- Server (origin) -> authority
	_server_ability_used.rpc_id(1, player.player_id)


func _weapon_switch() -> void:
	# client <- Server (origin) -> authority
	_server_switch.rpc_id(1, player.player_id)
#endregion
