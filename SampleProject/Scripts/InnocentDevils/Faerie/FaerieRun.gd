extends State
class_name FaerieRun
@export var wings: AnimationPlayer

func enter():
	animation.play("move_start", -1, 1.3)
	wings.play("normal")
	
func Update(delta: float):
	if not animation.is_playing() or animation.current_animation != "move_start":
		determineAnimation()
		
	if abs(player.position - Global.player.position).length_squared() <= Vector2(100, 100).length_squared():
		Transitioned.emit(self, "stop_moving")
	can_use_skill()
		
func Physics_Update(delta: float):
	player.velocity = Vector2(Global.player.position.x - player.position.x, Global.player.position.y - player.position.y - 30) / 1
	if sign(player.velocity.x)*player.facing_position < 0:
		turn_around()

func determineAnimation():
	if abs(player.velocity.y) > abs(player.velocity.x) and abs(player.velocity.x) < 300 and player.velocity.y > 0 and animation.current_animation != "dropping":
		animation.play("dropping", -1, 2)
		wings.play("normal")
	elif abs(player.velocity.y) > abs(player.velocity.x) and abs(player.velocity.x) < 300 and player.velocity.y < 0 and animation.current_animation != "rising":
		animation.play("rising", -1, 1)
		wings.play("normal")
	elif abs(player.velocity.y) < abs(player.velocity.x) and animation.current_animation != "running":
		animation.play("running", -1, 2)
		wings.play("running")
		
