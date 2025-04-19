extends State
class_name HectorWait

const ANIM_SPEED: float = 0.65
const BLEND: float = -1
const ANIM_NAME: String = "idle"
var can_perfect_guard: bool = false


func enter():
	Global.screen = Global.ScreenType.EVENT
	player.velocity.x = 0
	if animation.current_animation == "run":
		animation.play("run_end", -1, 1.5)
	else:
		animation.play(ANIM_NAME, BLEND, ANIM_SPEED)
		
func exit():
	Global.screen = Global.ScreenType.NONE
		
func Update(delta):
	if not animation.is_playing():
		animation.play(ANIM_NAME, BLEND, ANIM_SPEED)
