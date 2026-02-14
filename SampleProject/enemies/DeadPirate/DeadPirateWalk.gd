extends State
class_name DeadPirateWalk
const MIN_DURATION: float = 1.5
const MAX_DURATION: float = 2.5
var can_act: bool
const SPEED: float = 80

func enter():
	animation.play("walk")
	player.velocity.x = SPEED*player.facing_position
	can_act = false
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(func(): can_act = true)
	
func exit():
	player.velocity.x = 0

func Update(delta: float):
	enemy_can_die()
	can_turnaround_with_scale()
	if can_act or horizontal_distance_from_player() <= player.ATTACK_FROM_RANGE:
		if horizontal_distance_from_player() > player.ATTACK_FROM_RANGE:
			if player.playerInAir():
				Transitioned.emit(self, "antiair")
			else:
				if randi_range(0,2) > 0:
					can_act = false
					get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(func(): can_act = true)
				else:
					Transitioned.emit(self, "sneak")
		else:
			if player.playerInAir():
				Transitioned.emit(self, "antiair")
			else:
				Transitioned.emit(self, player.attacks.pick_random())

func Physics_Update(delta: float):
	pass
