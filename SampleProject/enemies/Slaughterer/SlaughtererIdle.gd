extends State
class_name SlaughtererIdle
@export var MAX_DISTANCE_FROM_PLAYER: float
@export var FIREBALL_SHOOTING_FREQUENCY_FROM_DISTANCE: int

func enter():
	animation.play("idle")
	
func exit():
	pass

func Update(delta: float):
	can_turnaround_with_scale()
	enemy_can_die()
	if player.activated_AI:
		if abs(Global.player.global_position.x - player.global_position.x) < MAX_DISTANCE_FROM_PLAYER:
			if randi_range(0, 1) == 0:
				Transitioned.emit(self, "punching")
			else:
				Transitioned.emit(self, "spitting")
		elif randi_range(0, FIREBALL_SHOOTING_FREQUENCY_FROM_DISTANCE) == 0:
			Transitioned.emit(self, "spitting")
		else:
			Transitioned.emit(self, "moving")
			
func Physics_Update(delta: float):
	pass
