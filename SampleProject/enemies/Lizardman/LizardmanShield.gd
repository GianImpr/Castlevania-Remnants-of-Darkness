extends State
class_name LizardmanShield
const MIN_DURATION: float = 0.5
const MAX_DURATION: float = 1
const DEFENSE_BOOST: int = 20
var drop_shield: bool
var finished: bool
@export var guard_sparkles: CPUParticles2D
@export var guard_audio: PolyphonicAudio

func enter():
	player.stats.DEF += DEFENSE_BOOST
	player.is_hurt = false
	drop_shield = false
	player.should_guard = false
	finished = false
	player.is_guarding = true
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(func(): drop_shield = true)
	animation.play("shield")
	
func exit():
	player.stats.DEF -= DEFENSE_BOOST

func Update(delta: float):
	enemy_can_die()
	can_turnaround_with_scale()
	
	if player.is_hurt:
		guard_sparkles.restart()
		guard_sparkles.emitting = true
		guard_audio.play_sound_effect_from_library("guard")
		player.is_hurt = false
		
	if drop_shield and not finished:
		animation.play_backwards("shield")
		finished = true
		return
		
	if finished and not animation.is_playing():
		player.is_guarding = false
		if player.activated_AI:
			Transitioned.emit(self, ["swing", "spit", "dash", "dash"].pick_random())
		else:
			Transitioned.emit(self, "idle")
		

func Physics_Update(delta: float):
	pass
