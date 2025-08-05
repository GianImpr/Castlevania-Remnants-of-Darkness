extends State
class_name WargMoving
@export var SPEED: float
@export var MAGIC_USAGE_FREQUENCY_FROM_DISTANCE: int = 200

func enter():
	player.velocity.x = SPEED * player.facing_position
	animation.play("walking")
	
func exit():
	pass

func Update(delta: float):
	if sign(player.facing_position) != sign(Global.player.global_position.x - player.global_position.x):
		Transitioned.emit(self, "turning")
	elif abs(Global.player.global_position.x - player.global_position.x) < WargIdle.MAX_ATTACK_DISTANCE:
		if randi_range(0, 1) == 0:
			Transitioned.emit(self, "preparing")
		else:
			Transitioned.emit(self, "magic")
	elif randi_range(0, MAGIC_USAGE_FREQUENCY_FROM_DISTANCE) == 0:
		Transitioned.emit(self, "magic")
	enemy_can_die()
