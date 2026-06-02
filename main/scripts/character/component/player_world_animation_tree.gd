@tool
extends AnimationTree
class_name PlayerAnimationTree

enum Holding {NOTHING, AR, PISTOL, SNIPER, MG, SMG, SHOTGUN}

@onready var body: Node3D = %Body
@onready var head: Node3D = %Head
@onready var player_collider: CollisionShape3D = %PlayerCollider


@export var equipped: Holding = Holding.NOTHING
@export var is_alive: bool = true:
	get():
		return is_alive
	set(value):
		is_alive = value
		if value:
			set("parameters/DeathBlend/blend_amount", 0)
		else:
			set("parameters/DeathBlend/blend_amount", 1)
			body.position.y = 0
@export var is_crouching: bool = false:
	get():
		return is_crouching
	set(value):
		is_crouching = value
		if !value:
			set("parameters/CrouchAdd/add_amount", 0)
			body.position.y = 0
			head.position.y = head_offset
			player_collider.shape.height = height
			player_collider.position.y = collision_offset
		else:
			set("parameters/CrouchAdd/add_amount", 1)
			body.position.y = crouch_offset
			head.position.y = crouch_head_offset
			player_collider.shape.height = crouch_height
			player_collider.position.y = crouch_collision_offset
@export var crouch_offset: float = 0:
	get():
		return crouch_offset
	set(value):
		crouch_offset = value
@export var head_offset: float = 0
@export var crouch_head_offset: float = 0:
	get():
		return crouch_head_offset
	set(value):
		crouch_head_offset = value
@export var height: float = 1.697
@export var crouch_height: float = 0.5
@export var collision_offset: float = 0
@export var crouch_collision_offset: float = 0.633
