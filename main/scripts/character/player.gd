extends Character
class_name PlayerCharacter

enum Classes {ASSAULT, SUPPORT}

var player_name: String = "something"
var steam_id: int = 0
var player_class: Classes = Classes.ASSAULT

#region Important Nodes
@onready var world_animation_tree: PlayerAnimationTree = %AnimationTree
@onready var weapon_manager: WeaponManager = $WeaponManager
@onready var look_ik: SkeletonIK3D = %LookIK
@onready var audio_listener_3d: AudioListener3D = %AudioListener3D
@onready var voice: AudioStreamPlayer3D = %Voice
@onready var camera_3d: Camera3D = %Camera3D
@onready var head: Node3D = %Head
@onready var weapon_raycast: RayCast3D = %WeaponRaycast
@onready var world_model: Node3D = %WorldModel
@onready var ui_component: PlayerUIComponent = $UIComponent
@onready var recoil: RecoilComponent = %Recoil
@onready var player_status_container: GridContainer = %PlayerStatusContainer
#endregion

@export var camera_sensitivity: float = 0.1
@export var status: StatusEffect

@export_group("Movement")
@export var move_speed: float = 5.0
@export var acceleration: float = 15.0
@export var jump_velocity: float = 4.0

@export_group("Proximity")
@export var has_loopback: bool = false
@export var max_distance: float = 30.0

var input_dir: Vector2 = Vector2.ZERO
var input_smoothed: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO

#region Proximity Variables
var current_sample_rate: int = 4800
var local_playback: AudioStreamGeneratorPlayback = null
var local_voice_buffer: PackedByteArray = PackedByteArray()
var network_playback: AudioStreamGeneratorPlayback = null
var network_voice_buffer: PackedByteArray = PackedByteArray()
var packet_read_limit: int = 5
#endregion

## see if the player is in combat. Used
var is_in_combat: bool
var can_crouch: bool = true
var is_moving: bool = false
var can_control: bool = true

signal Fire1
signal Fire2
signal WeaponAbilityUsed
signal Reload
signal WeaponSwitch

const FIRE_EFFECT = preload("uid://d11p8d7cucni3")


func _ready() -> void:
	current_speed = move_speed
	voice.max_distance = max_distance
	voice.stream.mix_rate = current_sample_rate
	voice.play()
	local_playback = voice.get_stream_playback()
	
	camera_3d.current = is_multiplayer_authority()
	audio_listener_3d.current = is_multiplayer_authority()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	look_ik.start()
	if is_multiplayer_authority():
		camera_3d.make_current()
		
	await get_tree().create_timer(1).timeout
	status_manager.server_add_debuff(status)
	print("Hello")

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	if can_control:
		input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
		input_smoothed = lerp(input_smoothed, input_dir, delta * 10.0)
		world_animation_tree.set("parameters/WalkBlendSpace2D/blend_position", input_smoothed)
	
	if is_on_floor():
		if Input.is_action_just_pressed("Jump"):
			velocity.y = jump_velocity
			world_animation_tree.set("parameters/JumpOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		handle_movement(delta)
	else:
		handle_gravity(delta)

	move_and_slide()

func _process(_delta: float) -> void:
	_check_firing()

# We're currently adding doing the player script
# from multiplayer template

## so we can use it in the process for automatic firing
func _check_firing() -> void:
	if !is_multiplayer_authority(): return
	if !health.is_dead and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_pressed("Fire1"):
			Fire1.emit()
		if Input.is_action_pressed("Fire2"):
			Fire2.emit()

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	if !health.is_dead && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED && can_control: # This might be prone to it being hijacked by client
		#if event.is_action_pressed("Fire1"):
			#Fire1.emit()
		#if event.is_action_pressed("Fire2"):
			#Fire2.emit()
		if event.is_action_pressed("WeaponAbility"):
			WeaponAbilityUsed.emit()
		if event.is_action_pressed("Reload"):
			Reload.emit()
		if event.is_action_pressed("SwitchWeapon"):
			WeaponSwitch.emit()
		if event.is_action_pressed("Ability1"):
			pass
		if event.is_action_pressed("Ability2"):
			pass
		if event.is_action_pressed("Ability3"):
			pass
		if event.is_action_pressed("Ability4"):
			pass
		if event.is_action_pressed("Crouch"):
			world_animation_tree.is_crouching = true
		if event.is_action_released("Crouch"):
			world_animation_tree.is_crouching = false
	else:
		world_animation_tree.is_crouching = false
	
	if event.is_action_pressed("OpenMenu"):
		if ui_component.show_menu:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			ui_component.show_menu = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			ui_component.show_menu = true
	
	if !ui_component.show_menu:
		# Something learned from Deadlock, holding this we can inspect hud element to gather more info
		if event.is_action_pressed("HUDInspect"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if event.is_action_released("HUDInspect"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * camera_sensitivity))
			head.rotate_x(deg_to_rad(-event.relative.y * camera_sensitivity))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))


#func _unhandled_input(event: InputEvent) -> void:
	#pass


func handle_gravity(delta: float) -> void:
	velocity += get_gravity() * delta


func handle_movement(delta: float) -> void:
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * acceleration)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

func reset_movement_multiplier() -> void:
	movement_multiplier = 1
	current_speed = weapon_manager.get_state_speed(weapon_manager.current_move_state) * movement_multiplier

## This adds or removes from the multiplier, it does not multiply.
func apply_movement_multiplier(multiplier: float) -> void:
	movement_multiplier = clampf(movement_multiplier + multiplier, 0, 5)
	current_speed = weapon_manager.get_state_speed(weapon_manager.current_move_state) * movement_multiplier 

# TODO: Hide world model and instantiate view model for themselves
func _show_view_model() -> void:
	if is_multiplayer_authority():
		pass


func _on_ingame_menu_back_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ui_component.show_menu = false
