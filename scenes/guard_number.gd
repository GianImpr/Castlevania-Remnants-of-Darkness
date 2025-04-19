extends ImageNumber
@export var label: TextureRect

func updateGuard():
	var can_guard = Global.player.stats.findItem(1, Global.player.stats.skill_inventory)
	var guard_count = Global.player.stats.Stats["Guard"]
	if guard_count <= 1:
		label.modulate = Color(1, 0.776, 0.302)
	else:
		label.modulate = Color(1, 1, 1)
	visible = false
	label.visible = false
	if visible:
		printNumber(guard_count)
