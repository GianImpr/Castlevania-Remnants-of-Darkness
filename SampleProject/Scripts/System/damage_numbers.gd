extends HBoxContainer
@export var damage_numbers: TextureRect
const NUMBER_WIDTH: int = 8;
const NUMBER_HEIGHT: int = 11;

func printNumber(value: int, type: int):
	for child in get_children():
		child.queue_free()
	for i in str(value):
		var num: TextureRect = damage_numbers.duplicate()
		num.visible = true
		num.texture = damage_numbers.texture.duplicate(true)
		num.texture.region = Rect2(int(i)*NUMBER_WIDTH, type*NUMBER_HEIGHT, NUMBER_WIDTH, NUMBER_HEIGHT)
		add_child(num)
