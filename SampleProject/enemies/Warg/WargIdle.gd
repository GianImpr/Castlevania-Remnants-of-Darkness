extends State
class_name WargIdle
static var MAX_ATTACK_DISTANCE: float = 200

func enter():
	player.velocity.x = 0
	animation.play("idle")
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if sign(player.facing_position) != sign(Global.player.global_position.x - player.global_position.x):
		Transitioned.emit(self, "turning")

	if player.activated_AI:
		if abs(Global.player.global_position.x - player.global_position.x) < MAX_ATTACK_DISTANCE:
			if randi_range(0, 1) == 0:
				Transitioned.emit(self, "preparing")
			else:
				Transitioned.emit(self, "magic")
		else:
			Transitioned.emit(self, "moving")

func Physics_Update(delta: float):
	pass
