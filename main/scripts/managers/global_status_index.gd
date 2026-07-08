extends Resource
## An index containing all status effects to make it easier to pick status effects through networks.
class_name GlobalStatusIndex

@export var statuses: Dictionary[String, StatusEffect]

## This is a safe way to use for networking
func grab_status_resource(name: String) -> StatusEffect:
	var status_effect: StatusEffect
	
	status_effect = statuses[name].duplicate(true)
	
	# So I want to create a .new
	# From the dictionary we can do Fire.new()
	
	return status_effect
