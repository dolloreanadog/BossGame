extends Character
class_name PlayerController

enum Classes {ASSAULT, SUPPORT}

var player_name: String = "something"
var steam_id: int = 0
var player_class: Classes = Classes.ASSAULT

#region Important Nodes
@onready var status_manager: StatusManager = $StatusManager
@onready var weapon_manager: WeaponManager = $WeaponManager
@onready var animation_tree: PlayerAnimationTree = %AnimationTree
@onready var look_ik: SkeletonIK3D = %LookIK
@onready var audio_listener_3d: AudioListener3D = %AudioListener3D
@onready var voice: AudioStreamPlayer3D = %Voice
@onready var camera_3d: Camera3D = %Camera3D
@onready var head: Node3D = %Head
#endregion

@export var camera_sensitivity: float = 0.1

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

signal Fire1
signal Fire2

func _ready() -> void:
	voice.max_distance = max_distance
	voice.stream.mix_rate = current_sample_rate
	voice.play()
	local_playback = voice.get_stream_playback()
	
	camera_3d.current = is_multiplayer_authority()
	audio_listener_3d.current = is_multiplayer_authority()
	
	look_ik.start()

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return

	input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	input_smoothed = lerp(input_smoothed, input_dir, delta * 10.0)
	animation_tree.set("parameters/WalkBlendSpace2D/blend_position", input_smoothed)

	if is_on_floor():
		if Input.is_action_just_pressed("Jump"):
			velocity.y = jump_velocity
			animation_tree.set("parameters/JumpOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		handle_movement(delta)
	else:
		handle_gravity(delta)

	move_and_slide()

func _process(delta: float) -> void:
	pass

# We're currently adding doing the player script
# from multiplayer template

func _input(event: InputEvent) -> void:
	if !health.is_dead:
		if event.is_action_pressed("Fire1"):
			if is_instance_valid(weapon_manager.weapon_1):
				Fire1.emit()
		if event.is_action_pressed("Fire2"):
			if is_instance_valid(weapon_manager.weapon_2):
				Fire2.emit()
		if event.is_action_pressed("Ability1"):
			pass
		if event.is_action_pressed("Ability2"):
			pass
		if event.is_action_pressed("Ability3"):
			pass
		if event.is_action_pressed("Ability4"):
			pass
		if event.is_action_pressed("Crouch"):
			animation_tree.is_crouching = true
		if event.is_action_released("Crouch"):
			animation_tree.is_crouching = false
	else:
		animation_tree.is_crouching = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * camera_sensitivity))
			head.rotate_x(deg_to_rad(-event.relative.y * camera_sensitivity))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func handle_gravity(delta: float) -> void:
	velocity += get_gravity() * delta


func handle_movement(delta: float) -> void:
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * acceleration)
	if direction:
		velocity.x = direction.x * get_speed()
		velocity.z = direction.z * get_speed()
	else:
		velocity.x = move_toward(velocity.x, 0, get_speed())
		velocity.z = move_toward(velocity.z, 0, get_speed())


func get_speed() -> float:
	return move_speed



# TODO: Hide world model and instantiate view model for themselves
func _show_view_model() -> void:
	if is_multiplayer_authority():
		pass
