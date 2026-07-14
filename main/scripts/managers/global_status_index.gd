extends Resource
## An index containing all status effects to make it easier to pick status effects through networks.
class_name GlobalStatusIndex

@export var statuses: Dictionary[String, StatusEffect]

## Grabs status from our dictionary
func get_effect(id: String) -> StatusEffect:
	return statuses[id]
