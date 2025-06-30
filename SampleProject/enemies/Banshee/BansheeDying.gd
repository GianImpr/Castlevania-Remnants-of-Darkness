extends State
class_name BansheeDying

func enter():
	player.velocity = Vector2(0, 0)
	animation.play("dying")
	player.hitbox.monitoring = false
	player.yelling_hitbox.monitoring = false
	for child in player.sprite.get_children():
		if child is Sprite2D:
			child.visible = false
	
func Update(delta: float):
	pass


func Physics_Update(delta: float):
	pass
