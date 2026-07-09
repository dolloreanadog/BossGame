extends CharacterBody3D
class_name Character

@export var health: HealthComponent
## This will hold the various aoe the character will do.
@export var status_manager: StatusManager # Marked to move to Character

var current_speed: float = 1
var movement_multiplier: float = 1
