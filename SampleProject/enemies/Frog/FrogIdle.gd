extends State
class_name FrogIdle
const MIN_DURATION: float = 0.5
const MAX_DURATION: float = 2
var can_act: bool
const MIN_TONGUE_DISTANCE: float = 90
@export var noise_timer_interval: Timer

func enter():
	if not noise_timer_interval.timeout.is_connected(sound.play_sound_effect_from_library):
		noise_timer_interval.timeout.connect(sound.play_sound_effect_from_library.bind("noise"))
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(Transitioned.emit.bind(self, decideAction()))
	animation.play("idle")
	sound.play_sound_effect_from_library("noise")
	noise_timer_interval.start()
	player.velocity = Vector2.ZERO
	
func exit():
	noise_timer_interval.stop()

func Update(delta: float):
	enemy_can_die()
	can_turnaround_with_scale()

func Physics_Update(delta: float):
	pass

func decideAction() -> String:
	if abs(Global.player.global_position.x - player.global_position.x) < MIN_TONGUE_DISTANCE:
		return ["tongue", "tongue", "tongue", "jump"].pick_random()
	return "jump"
