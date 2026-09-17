extends State
class_name HectorIdle

const ANIM_SPEED: float = 0.65
const BLEND: float = -1
var can_perfect_guard: bool = true

func enter():
	if player != null and player.isWeak():
		animation.play("idle_weak")
	else:
		animation.play(player.Animations.IDLE, BLEND, ANIM_SPEED)
	
func Update(delta: float):
	can_perform(Actions.JUMP, true)
	can_perform(Actions.BACKDASH, true)
	can_perform(Actions.CROUCH, false)
	check_is_hurt()
	can_guard()
	can_attack()
	can_die()
	run_without_start_anim(false)
	can_fall(true)
	can_pose()
		
	if not animation.is_playing():
		if player.isWeak():
			animation.play_backwards("idle_weak")
		else:
			animation.play(player.Animations.IDLE, BLEND, ANIM_SPEED)
			
	if animation.current_animation == "idle_weak" and player.isWeak():
		if animation.current_animation_position <= 0.64 and animation.get_playing_speed() < 0:
			animation.play("idle_weak", -1)
			animation.seek(0.64)
	elif animation.current_animation == "idle_weak" and not player.isWeak() and animation.current_animation_position <= 0.05 and animation.get_playing_speed() > 0:
		animation.play(player.Animations.IDLE, BLEND, ANIM_SPEED)
