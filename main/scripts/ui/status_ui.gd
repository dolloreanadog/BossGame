extends Control
class_name StatusUI

@export var status_icon: TextureRect
@export var time_label: Label
@export var name_label: Label
@export var stacks_label: Label

var hover_text: String:
	get():
		return tooltip_text
	set(text):
		tooltip_text = text

func update_time(new_time: int) -> void:
	time_label.text = str(new_time)

func update_stacks(new_stacks: int) -> void:
	stacks_label.text = str(new_stacks)
