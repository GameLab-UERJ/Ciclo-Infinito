extends CharacterBody2D
class_name Character


func has_status(status_data : StatusData) -> bool:
	var statuses : Array[Status]	= self.find_children("*", "Status", true, false) as Array[Status]
	for stat : Status in statuses:
		if stat.status_data == status_data:
			return true
	return false


func has_bonus(bonus : Bonus) -> bool:
	var bonuses : Array[Bonus]		= self.find_children("*", "Bonus", true, false) as Array[Bonus]
	for bon : Bonus in bonuses:
		if bon.get_class() == bonus.get_class():
			return true
	return false
