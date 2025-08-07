extends Node2D
class_name PlayerProjectile

var facing_position: int = 1

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if Global.player != null:
		if Global.player.facing_position != facing_position:
			scale.x *= -1
			facing_position *= -1
