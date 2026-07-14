@icon("uid://bmpghfb1tyte5")
@abstract
extends Resource
class_name StatusEffect

@export var id: String
@export_subgroup("Visible")
@export var display_name: String
@export var icon: Texture2D
@export var max_stacks: int = 1
@export var duration: int
@export var hover_text: String

@abstract
func server_apply_effect(target: Character, stacks: int, player: PlayerCharacter = null) -> void;
# if !multiplayer.is_server: return
# Then we can have if is_valid_instance(player)
# Then we can do like damage.rpc(something)

@abstract
func server_remove_effect(target: Character, stacks: int, player: PlayerCharacter = null) -> void;
# if !multiplayer.is_server: return
# Then we can have if is_valid_instance(player)
# Then we can do like damage.rpc(something)

@abstract
func server_time_effect(target: Character, stacks: int, player: PlayerCharacter = null) -> void;
# if !multiplayer.is_server: return
# Then we can have if is_valid_instance(player)
# Then we can do like damage.rpc(something)
