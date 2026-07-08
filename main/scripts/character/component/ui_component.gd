@icon("uid://dj5neeqj8rijx")
extends PlayerComponent
class_name PlayerUIComponent

## TODO: We need to connect player stuff to this UI Component

@onready var health_label: Label = %HealthLabel
@onready var ammo_label: Label = %AmmoLabel
@onready var boss_health_bar: ProgressBar = $"../UI/HUD/BossInfo/BossHealthBar"
@onready var boss_name_label: Label = $"../UI/HUD/BossInfo/BossNameLabel"
@onready var boss_attack_label: Label = $"../UI/HUD/BossInfo/BossAttackLabel"
@onready var boss_info: Control = $"../UI/HUD/BossInfo"
@onready var player_status_container: GridContainer = %PlayerStatusContainer
@onready var ability_container: HBoxContainer = %AbilityContainer
@onready var mini_map: ColorRect = %MiniMap
@onready var ingame_menu: Control = $"../UI/IngameMenu"
@onready var warning_ui: TextureRect = %WarningUI

# Should count for shield + current_health
var health: float:
	set(value):
		health = snappedf(value, 1)
		if is_instance_valid(health_label):
			health_label.text = str(health) + "%"

## Only update "max_ammo" when we update weapon switch
var max_ammo: int
var ammo: int:
	set(value):
		ammo = value
		update_ammo()

var boss_name: String:
	set(value):
		boss_name = value
		boss_name_label.text = value

var attack_name: String:
	set(value):
		attack_name = value
		boss_attack_label.text = value

var boss_health: float:
	set(value):
		boss_health = value
		boss_health_bar.value = value

var show_menu: bool:
	get():
		return ingame_menu.visible
	set(value):
		ingame_menu.visible = value

var show_warning: bool:
	get():
		return warning_ui.visible
	set(value):
		warning_ui.visible = value

func show_boss_stats(show: bool) -> void:
	if show:
		boss_info.show()
	else:
		boss_info.hide()

func import_boss_info(new_max_health: float, new_boss_name: String) -> void:
	boss_health_bar.max_value = new_max_health
	boss_health_bar.value = new_max_health
	boss_name_label.text = new_boss_name

func update_ammo() -> void:
	ammo_label.text = "%s/%s" % [ammo, max_ammo]


func _on_health_component_health_changed(amount: float) -> void:
	health = amount


func _on_weapon_manager_ammo_changed(new_ammo: int) -> void:
	ammo = new_ammo


func _on_weapon_manager_weapon_switch(new_ammo: int, new_max_ammo: int) -> void:
	print("new max ammo: %s" % [new_max_ammo])
	max_ammo = new_max_ammo
	ammo = new_ammo
	update_ammo()
