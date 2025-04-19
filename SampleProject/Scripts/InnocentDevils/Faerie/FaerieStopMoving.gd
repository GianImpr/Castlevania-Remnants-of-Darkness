extends State
class_name FaerieStopMoving
@export var wings: AnimationPlayer

func enter():
	animation.play("stopping", -1, 1.3)
	wings.play("normal")
	player.velocity *= 0.4
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
		
	if abs(player.position - Global.player.position) > Vector2(150, 150):
		Transitioned.emit(self, "run")
	can_use_skill()
