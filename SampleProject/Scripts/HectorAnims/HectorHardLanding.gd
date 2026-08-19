extends State
class_name HectorHardLanding
var can_perfect_guard: bool = false
const MOMENTUM_MULTIPLIER: float = 0.3
static var applyMercyInvincibility: Callable
const SOLDIER_BOOTS_MULTIPLIER: float = 1.5

func enter():
	animation.play("hard_landing", -1, 1.7)
	sound.play_sound_effect_from_library("hard_landing")
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	player.velocity.x *= MOMENTUM_MULTIPLIER
	can_fall(false)
	can_die()
	can_guard()
	
	if InputBuffer.is_action_press_buffered("jump") and Input.is_action_pressed("crouch") and not player.is_hurt:
		Transitioned.emit(self, "slide")
	
	if InputBuffer.is_action_press_buffered("backdash") and player.is_hurt and (Global.screen != Global.ScreenType.TRAINING or player.stats.Stats["HP"] > 0):
		TrainingSettings.spawnTrainingHeart(TrainingMode.Training.QUICK_RECOVER)
		Transitioned.emit(self, "backdash")
		player.is_hurt = false
		if player.stats.itemEquipped(Legs.Leg.SOLDIER_BOOTS, "legs"):
			applyMercyInvincibility.call(player.SHORT_MERCY_INVINCIBILITY_DURATION*SOLDIER_BOOTS_MULTIPLIER)
		else:
			applyMercyInvincibility.call(player.SHORT_MERCY_INVINCIBILITY_DURATION)

	if not animation.is_playing() and (Global.screen != Global.ScreenType.TRAINING or player.stats.Stats["HP"] > 0):
		stay_crouched()
		player.is_hurt = false
