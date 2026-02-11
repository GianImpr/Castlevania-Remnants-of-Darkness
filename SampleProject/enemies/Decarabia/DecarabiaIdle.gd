extends State
class_name DecarabiaIdle
const SPEED: float = 100
const ACCELERATION_DURATION: float = 0.5
const IDLE_MIN_DURATION: float = 0.5
const IDLE_MAX_DURATION: float = 3
var acceleration_tween: Tween

func enter():
	can_turnaround_with_scale()
	acceleration_tween = get_tree().create_tween()
	acceleration_tween.tween_property(player, "velocity:x", SPEED*player.facing_position, ACCELERATION_DURATION)
	get_tree().create_timer(randf_range(IDLE_MIN_DURATION, IDLE_MAX_DURATION), false).timeout.connect(Transitioned.emit.bind(self, "turbo"))

func exit():
	acceleration_tween.kill()

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass
