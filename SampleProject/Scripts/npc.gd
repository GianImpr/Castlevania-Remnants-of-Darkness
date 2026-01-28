extends Sprite2D
class_name NPC
@export var sprite: Sprite2D
@export var animation: AnimationPlayer
var facing_position: int = 1

func playAnim(anim_name: String) -> void:
	animation.play(anim_name)
	
func turnLeft() -> void:
	if facing_position == -1:
		return
	facing_position = -1
	scale.x *= -1
	
func turnRight() -> void:
	if facing_position == 1:
		return
	facing_position = 1
	scale.x *= -1
