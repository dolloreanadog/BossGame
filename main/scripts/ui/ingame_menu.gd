@icon("uid://bj3xdou4385jn")
extends Control
class_name IngameMenu

@onready var players_container: VBoxContainer = $PlayersPanel/ScrollContainer/PlayersContainer

const PLAYER_INFO_CONTAINER = preload("uid://ctmor2xy713hk")

signal back_button_pressed

## This will put players in lobby into the list so we can mute or stuff
func update_player_container() -> void:
	pass


func _on_back_button_pressed() -> void:
	back_button_pressed.emit()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_menu_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_game_button_pressed() -> void:
	get_tree().quit()
