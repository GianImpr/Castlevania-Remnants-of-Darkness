extends State
class_name BonePillarTurning

func enter():
	animation.play("turn", -1, 1)
	
func Update(_delta: float):
	if not animation.is_playing():
		player.sprite.frame = 1
		player.sprite.scale.x *= -1
		player.facing_position *= -1
		Transitioned.emit(self, "idle")
	enemy_can_die(false)
