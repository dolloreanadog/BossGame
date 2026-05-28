extends Node

# INFO: These will be equipped weapons
var weapon1_id: int
var weapon2_id: int

var unlocked_weapons: Array[int]
## Contains all the boss id the player has beaten
var beaten_bosses: Array[int]
## This is the currency used to buy weapons and abilities
var credits: int

## This is unneeded I just wanted to show multiplayer.is_server()
var is_host: bool
