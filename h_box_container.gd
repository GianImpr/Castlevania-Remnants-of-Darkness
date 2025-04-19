extends HBoxContainer
class_name ImageNumber

var path = "res://assets/sprites/HUD/Numbers/"

func updateHP(_HP, _MHP):
	if _HP <= _MHP/4:
		modulate = Color(1, 0.776, 0.302)
	else:
		modulate = Color(1, 1, 1)
	printNumber(_HP)
	
func printNumber(value: int):
	for child in get_children():
		child.queue_free()
	for i in str(value):
		var num = TextureRect.new()
		add_child(num)
		num.custom_minimum_size = Vector2(9, 1.4)
		num.stretch_mode = TextureRect.STRETCH_SCALE
		num.texture = load(path + i + ".png")
		
