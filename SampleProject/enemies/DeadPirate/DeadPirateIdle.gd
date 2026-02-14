extends State
class_name DeadPirateIdle
const MIN_DURATION: float = 0.5
const MAX_DURATION: float = 1
var can_act: bool

func enter():
	animation.play("idle")
	can_act = false
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(func(): can_act = true)
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	can_turnaround_with_scale()
	if (can_act or player.playerInAir()) and player.activated_AI:
		if horizontal_distance_from_player() > player.ATTACK_FROM_RANGE:
			Transitioned.emit(self, "walk")
		else:
			if player.playerInAir():
				Transitioned.emit(self, "antiair")
			else:
				Transitioned.emit(self, player.attacks.pick_random())

func Physics_Update(delta: float):
	pass
