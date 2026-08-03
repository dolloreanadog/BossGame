extends NewWeapon
class_name WeaponTestAR

#region Server Methods

## This is a server method, it's an rpc because authority calls the ability, so we need to send to server [br]
## Then we do the calculations and send the confirmations back to the player like visuals and sound. [br][br]
## This should be how the function should be usually structured:
## [codeblock]
## func use_ability() -> void:
## 	if player.multiplayer.is_server():
## 	do stuff
## 	Then sync it like sync_use_ability.rpc(stuff, stuff)
## [/codeblock]
@rpc("any_peer", "call_local", "reliable")
func use_ability() -> void:
	pass


## This is a server method, it's an rpc because authority calls the shooting, so we need to send to server [br]
## Then we do the calculations and send the confirmations back to the player like visuals and sound.
@rpc("any_peer", "call_local", "reliable")
func shoot_1() -> void:
	power += 1
	current_damage_add_1 = power


## This is a server method, it's an rpc because authority calls the shooting, so we need to send to server [br]
## Then we do the calculations and send the confirmations back to the player like visuals and sound.
@rpc("any_peer", "call_local", "reliable")
func shoot_2() -> void:
	pass


## This is a server method, it's an rpc because authority calls the reload, so we need to send to server [br]
## Then we do the calculations and send the confirmations back to the player like visuals and sound.
@rpc("any_peer", "call_local", "reliable")
func reload() -> void:
	power = 0
	reset_stat(weapon_stat.DAMAGE, false)
#endregion

## These are all are private since only this script needs to use these.
#region All Clients
## Accepts assortment of values.
## If not player.is_multiplayer_authority(): 
@rpc("any_peer", "call_local", "reliable")
func _sync_client_use_ability(...args: Array) -> void:
	pass 


## Accepts assortment of values.
## If not player.is_multiplayer_authority():
@rpc("any_peer", "call_local", "reliable")
func _sync_client_shoot1(...args: Array) -> void:
	pass 


## Accepts assortment of values.
## If not player.is_multiplayer_authority():
@rpc("any_peer", "call_local", "reliable")
func _sync_client_shoot2(...args: Array) -> void:
	pass 


## Accepts assortment of values.
## If not player.is_multiplayer_authority():
@rpc("any_peer", "call_local", "reliable")
func _sync_client_reload(...args: Array) -> void:
	pass 
#endregion

## These are all are private since only this script needs to use these.
## This code region only applies to the one that shot preferably, show icon and ammo on cooldown.
#region Authority
## Accepts assortment of values.
## If player.is_multiplayer_authority():
@rpc("any_peer", "call_local", "reliable")
func _sync_authority_use_ability(...args: Array) -> void:
	pass


## Accepts assortment of values.
## If player.is_multiplayer_authority():
@rpc("any_peer", "call_local", "reliable")
func _sync_authority_shoot1(...args: Array) -> void:
	pass


## Accepts assortment of values.
## If player.is_multiplayer_authority():
@rpc("any_peer", "call_local", "reliable")
func _sync_authority_shoot2(...args: Array) -> void:
	pass


## Accepts assortment of values.
## If player.is_multiplayer_authority():
@rpc("any_peer", "call_local", "reliable")
func _sync_authority_reload(...args: Array) -> void:
	pass
#endregion
