extends Node2D

@export var speed:float = 600
var direction:Vector2 = Vector2.ZERO


func _ready():
	await get_tree().create_timer(5).timeout
	queue_free()


func _process(delta):
	position += speed * direction * delta
