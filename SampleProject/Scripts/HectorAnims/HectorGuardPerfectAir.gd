extends State
class_name HectorGuardPerfectAir
var can_perfect_guard: bool = true
const INITIAL_HEIGHT_BOOST: float = -300

func enter():
	animation.play("perfect_guarding_air", -1, 2.8)
	sound.play_sound_effect_from_library("perfect_guard")
	player.velocity.y = INITIAL_HEIGHT_BOOST
	
	if player.stats.canApplySkill(Skill.Skills.AWARENESS):
		player.focus_gain_duration.start()


func exit():
	player.is_hurt = false
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_die()
	can_land()
	
	can_move_with_momentum(player.velocity.y < 0)
	
	if not animation.is_playing():
		Transitioned.emit(self, "falling")
