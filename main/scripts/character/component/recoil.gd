extends Node3D
class_name RecoilComponent

# Rotations
var currentRotation : Vector3
var targetRotation : Vector3

# Recoil vectors
## Rotation vector added to the target rotation whenever [RecoilComponent.recoilFire] is called
@export var recoil : Vector3
## Rotation vector added to the target rotation whenever [RecoilComponent.recoilFire] = true is called
@export var altRecoil : Vector3

# Settings
## Rate at which the current rotation lerps to the target rotation
@export var snappiness : float = 1
## Rate at which the target rotation returns to (0, 0, 0)
@export_range(0, 100, 1) var returnSpeed : float = 50

func _process(delta: float) -> void:
	# Lerp target rotation to (0,0,0) and lerp current rotation to target rotation
	targetRotation = lerp(targetRotation, Vector3.ZERO, returnSpeed * delta)
	currentRotation = lerp(currentRotation, targetRotation, snappiness * delta)
	
	# Set rotation
	rotation = currentRotation
	
	# Camera z axis tilt fix, ignored if tilt intentional
	# I have no idea why it tilts if recoil.z is set to 0
	if recoil.z == 0 and altRecoil.z == 0:
		global_rotation.z = 0

func recoilFire(multiplier: float = 1) -> void:
	targetRotation += Vector3(recoil.x, randf_range(-recoil.y, recoil.y), randf_range(-recoil.z, recoil.z)) * multiplier
