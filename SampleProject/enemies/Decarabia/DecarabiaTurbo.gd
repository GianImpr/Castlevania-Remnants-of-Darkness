extends State
class_name DecarabiaTurbo
@export var dash: Sprite2D
@export var sound_interval_timer: Timer
const SPEED: float = 300
const ACCELERATION_DURATION: float = 0.5
const MIN_DURATION: float = 3
const MAX_DURATION: float = 5
var acceleration_tween: Tween

func enter():
	if not sound_interval_timer.timeout.is_connected(sound.play_sound_effect_from_library):
		sound_interval_timer.timeout.connect(sound.play_sound_effect_from_library.bind("splash"))
	can_turnaround_with_scale()
	sound_interval_timer.start()
	sound.play_sound_effect_from_library("splash")
	acceleration_tween = get_tree().create_tween()
	acceleration_tween.tween_property(player, "velocity:x", SPEED*player.facing_position, ACCELERATION_DURATION)
	dash.visible = true
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(Transitioned.emit.bind(self, "idle"))

func exit():
	sound_interval_timer.stop()
	acceleration_tween.kill()
	dash.visible = false

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass
