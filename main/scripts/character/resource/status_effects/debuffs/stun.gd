extends StatusEffect
class_name StunEffect

func server_apply_effect(target: Character, stacks: int, player: PlayerCharacter = null) -> void:
	pass
# if !multiplayer.is_server: return
# Then we can have if is_valid_instance(player)
# Then we can do like damage.rpc(something)


func server_remove_effect(target: Character, stacks: int, player: PlayerCharacter = null) -> void:
	player.can_control = false
	print("can control = false")


func server_time_effect(target: Character, stacks: int, player: PlayerCharacter = null) -> void:
	player.can_control = true
	print("can control = true")
