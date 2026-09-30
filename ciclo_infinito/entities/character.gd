extends CharacterBody2D
class_name Character


func has_status(status : Status) -> bool:
	var statuses : Array[Status] = self.find_children("*", "Status", true, false) as Array[Status]
	for stat : Status in statuses:
		if stat.get_class() == status.get_class():
			return true
	return false
