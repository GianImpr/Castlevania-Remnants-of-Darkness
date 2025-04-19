extends Node
class_name Hour

var time: Dictionary = {"milliseconds": 0., "seconds": 0, "minutes": 0, "hours": 0}

# Keeps track of the elapsed time within a frame
func count(delta):
	time["milliseconds"] += delta*1000
	convertToIfGreaterThan("milliseconds", "seconds", 1000)
	convertToIfGreaterThan("seconds", "minutes", 60)
	convertToIfGreaterThan("minutes", "hours", 60)
	
func convertToIfGreaterThan(measure_unit, next_measure_unit, limit):
	if time[measure_unit] >= limit:
		time[measure_unit] -= limit
		time[next_measure_unit] += 1

func _to_string() -> String:
	return "%3d" % time["hours"] + ":" + "%02d" % time["minutes"] + ":" + "%02d" % time["seconds"]
