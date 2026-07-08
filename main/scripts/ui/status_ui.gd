extends Control
class_name StatusUI

@onready var status_icon: TextureRect = $StatusIcon
@onready var time_label: Label = $TimeLabel
@onready var name_label: Label = $NameLabel

var hover_text: String:
	get():
		return tooltip_text
	set(text):
		tooltip_text = text

func update_time(new_time: int) -> void:
	time_label.text = str(new_time)
