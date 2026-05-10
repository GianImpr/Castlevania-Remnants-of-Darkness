extends State
class_name HectorWait

const ANIM_SPEED: float = 0.65
const BLEND: float = -1
const ANIM_NAME: String = "idle"
var can_perfect_guard: bool = false
var starting_from_midair: bool = false
var has_to_land: bool = false
static var resumeAttackAnimation: Callable

func enter():
	if player.resume_attack:
		resumeAttackAnimation.call()
	starting_from_midair = not player.is_on_floor()
	if Global.screen != Global.ScreenType.TRAINING:
		Global.screen = Global.ScreenType.EVENT
	player.velocity.x = 0
	if player.is_on_floor():
		if animation.current_animation == "run" or animation.current_animation == "run_start":
			animation.play("run_end", -1, 1.5)
			await animation.animation_finished
			animation.play(ANIM_NAME, BLEND, ANIM_SPEED)
		elif not animation.is_playing() or animation.current_animation == "pose":
			animation.play(ANIM_NAME, BLEND, ANIM_SPEED)
	else:
		has_to_land = true
		const FALL_ANIM_STARTING_FRAME: float = 0.5
		if not animation.is_playing():
			animation.play("jump", -1, 1.5)
			animation.seek(FALL_ANIM_STARTING_FRAME)
		
func exit():
	Global.screen = Global.ScreenType.NONE
		
func Update(delta):
	if starting_from_midair and player.is_on_floor() and has_to_land:
		has_to_land = false
		animation.play("landing", -1, 1.5)
		await animation.animation_finished
		animation.play(ANIM_NAME, BLEND, ANIM_SPEED)
		
	if not animation.is_playing():
		animation.play(ANIM_NAME, BLEND, ANIM_SPEED)
