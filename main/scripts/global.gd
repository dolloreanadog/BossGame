extends Node

# INFO: These will be equipped weapons
var weapon1_id: int
var weapon2_id: int

var unlocked_weapons: Array[int]
## Contains all the boss id the player has beaten
var beaten_bosses: Array[int]
## This is the currency used to buy weapons and abilities
var credits: int

## @deprecated: This is unneeded I just wanted to show multiplayer.is_server()
var is_host: bool
var players: Array[int]

var game_controller: GameController
var enemy_aoe_container: Node3D
var player_aoe_container: Node3D
var decal_container: Node3D
const global_status_index = preload("uid://burv41bikvi0y")

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	game_controller = get_tree().get_current_scene().get_node("/root/GameController")
	enemy_aoe_container = game_controller.get_node("%EnemyAOEContainer")
	player_aoe_container = game_controller.get_node("%PlayerAOEContainer")
	decal_container = game_controller.get_node("%DecalContainer")
