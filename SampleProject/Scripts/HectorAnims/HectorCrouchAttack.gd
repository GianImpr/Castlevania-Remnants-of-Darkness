extends State
class_name HectorCrouchAttack
var can_perfect_guard: bool = false
const FIST_ANIMATION_SPEED_BOOST: float = 3
const FIST_ANIMATION_CANCELLABLE_FROM: float = 1.2
static var getWeaponAttackSound: Callable
static var getHectorAttackSound: Callable

func enter():
	playAttackAnimation()
	
func exit():
	if player.sprite.weapon != null:
		player.sprite.weapon.stop()
	
func Update(delta: float):
	remove_momentum()
	
func Physics_Update(delta: float):
	can_fall(true)
	check_is_hurt()
	can_die()
	
	if animation.current_animation == "crouch_attack_fist" and animation.current_animation_position >= FIST_ANIMATION_CANCELLABLE_FROM and InputBuffer.is_action_press_buffered("attack"):
		can_turn()
		playAttackAnimation()
		getWeaponAttackSound.call()
		getHectorAttackSound.call()
	
	if not animation.is_playing():
		stay_crouched()
		
func playAttackAnimation() -> void:
	var anim_speed = get_attack_speed()
	var anim_suffix = attack_anim_suffix()
	if anim_suffix == "_fist":
		anim_speed += FIST_ANIMATION_SPEED_BOOST
	animation.play("crouch_attack" + anim_suffix, -1, anim_speed)
	animation.seek(0)
	
