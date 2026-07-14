extends GridContainer
class_name StatusUIContainer

## This is a packed scene, but we're asking for Status UI
@export var status_ui_scene: PackedScene
@export var status_manager: StatusManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	status_manager.effects_updated.connect(_on_effects_updated)

func create_status_ui(effect_id: String, state: Dictionary) -> void:
	var status_ui: StatusUI = status_ui_scene.instantiate()
	
	var resource: Resource = Global.global_status_index.get_effect(effect_id)
	
	print(state)
	status_ui.status_icon.texture = resource.icon
	status_ui.name_label.text = resource.display_name
	status_ui.update_stacks(state["stacks"])
	status_ui.update_time(state["duration"])
	status_ui.hover_text = resource.hover_text
	
	add_child(status_ui)

func _on_effects_updated(active_effects: Dictionary) -> void:
	for child: Node in get_children():
		child.queue_free()
		print("Clear Effects")
	
	for effect_id: String in active_effects.keys():
		create_status_ui(effect_id, active_effects[effect_id])
		print("Update Effects")
