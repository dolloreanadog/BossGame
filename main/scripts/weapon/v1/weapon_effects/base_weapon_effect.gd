@abstract
extends GDScript
class_name WeaponEffect

var weapon_resource: Weapon
var player: PlayerCharacter



## What other things that happen when the player either shoot1, shoot2, use ability, or reloads
@abstract
@rpc("any_peer", "call_local", "reliable")
func use_effect() -> void;
