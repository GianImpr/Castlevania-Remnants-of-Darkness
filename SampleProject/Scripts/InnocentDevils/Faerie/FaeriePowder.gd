extends State
class_name FaeriePowder
var target: CharacterBody2D = null

func enter():
	if not player.targeted_enemy:
		Transitioned.emit(self, "idle")
	else:
		target = player.targeted_enemy
	animation.play("move_start")
	
func Update(delta: float):
	if not animation.is_playing() or animation.current_animation != "move_start":
		determineAnimation()
		
	if not target:
		Transitioned.emit(self, "idle")
		player.lock_current_skill = false
		
	if target and abs(player.position - target.position).length_squared() <= Vector2(100, 100).length_squared():
		if sign(target.position.x - player.position.x)*player.facing_position < 0:
			turn_around()
		Transitioned.emit(self, "healing")
		
func Physics_Update(delta: float):
	if target:
		player.velocity = Vector2(target.position.x - player.position.x, target.position.y - player.position.y - 30) * 3
	if sign(player.velocity.x)*player.facing_position < 0:
		turn_around()

func determineAnimation():
	if abs(player.velocity.y) > abs(player.velocity.x) and abs(player.velocity.x) < 300 and player.velocity.y > 0 and animation.current_animation != "dropping":
		animation.play("dropping")
	elif abs(player.velocity.y) > abs(player.velocity.x) and abs(player.velocity.x) < 300 and player.velocity.y < 0 and animation.current_animation != "rising":
		animation.play("rising")
	elif abs(player.velocity.y) < abs(player.velocity.x) and animation.current_animation != "running":
		animation.play("running")
