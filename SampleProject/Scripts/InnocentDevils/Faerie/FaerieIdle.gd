extends State
class_name FaerieIdle
@export var wings: AnimationPlayer
var period: int = 0

func enter():
	animation.play("idle")
	wings.play("normal")
	
func Update(delta: float):
	if abs(player.position - Global.player.position).length_squared() > Vector2(150, 150).length_squared():
		Transitioned.emit(self, "run")
	can_use_skill()
		
func Physics_Update(delta: float):
	period = (period+1)%360
	var step = float(period)/360*PI*2
	player.velocity = Vector2(25*sin(step), 25*cos(step))
