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
@onready var recoil_ik: SkeletonIK3D = %RecoilIK
@onready var audio_listener_3d: AudioListener3D = %AudioListener3D
@onready var voice: AudioStreamPlayer3D = %Voice
@onready var camera_3d: Camera3D = %Camera3D
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

func _physics_process(delta: float) -> void:
	pass

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if !health.is_dead:
		if event.is_action_pressed("Fire1"):
			if is_instance_valid(weapon_manager.weapon1):
				Fire1.emit()
		if event.is_action_pressed("Fire2"):
			if is_instance_valid(weapon_manager.weapon2):
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
		else:
			animation_tree.is_crouching = false
	else:
		animation_tree.is_crouching = false

# TODO: Hide world model and instantiate view model for themselves
func _show_view_model() -> void:
	if is_multiplayer_authority():
		pass
