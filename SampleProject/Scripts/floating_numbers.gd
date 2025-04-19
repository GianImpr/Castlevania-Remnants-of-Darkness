extends Marker2D
@export var damage_value: int
@export var label: Label
@export var damage_container: HBoxContainer
var type: int
var colors: Array[Color] = [Color(0.827, 0, 0.239), Color(0.945, 0.651, 0), Color(0.376, 0.915, 0), Color(0.3, 0, 0.9)]

func _ready() -> void:
	if damage_value <= 0:
		queue_free()
	damage_container.printNumber(damage_value, type)
