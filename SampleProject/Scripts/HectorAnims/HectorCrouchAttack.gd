extends State
class_name HectorCrouchAttack
var can_perfect_guard: bool = true
const FIST_ANIMATION_CANCELLABLE_FROM: float = 0.48
static var getWeaponAttackSound: Callable
static var getHectorAttackSound: Callable
const WEAPON_ANIMATION_DELAY: float = 0.01
@export var hector_hands: Sprite2D
const DEFAULT_HAND_FRAME: int = 6

func enter():
	playAttackAnimation()
	
func exit():
	if player.sprite.weapon != null:
		player.sprite.weapon.stop()
	hector_hands.visible = false
	
func Update(delta: float):
	remove_momentum()
	
func Physics_Update(delta: float):
	can_fall(true)
	check_is_hurt()
	can_die()
	
	if animation.current_animation == "crouch_attack_fist" and animation.current_animation_position >= FIST_ANIMATION_CANCELLABLE_FROM and InputBuffer.is_action_press_buffered("attack"):
		can_turn()
		playAttackAnimation()
		if Global.player.sprite.weapon != null:
			get_tree().create_timer(WEAPON_ANIMATION_DELAY).timeout.connect(playWeaponAnim)
		getWeaponAttackSound.call()
		getHectorAttackSound.call()
	
	if not animation.is_playing():
		stay_crouched()
		
func playAttackAnimation() -> void:
	var anim_speed = get_attack_speed()
	var anim_suffix = attack_anim_suffix()
	if anim_suffix == "_spear":
		hector_hands.frame = DEFAULT_HAND_FRAME
		hector_hands.visible = true
	elif anim_suffix == "_fist" and player.direction == player.facing_position:
		anim_suffix = "_fist_diag"
	animation.play("crouch_attack" + anim_suffix, -1, anim_speed)
	animation.seek(0)

func playWeaponAnim() -> void:
	Global.player.sprite.weapon.play_crouch(get_attack_speed(), false)
	Global.player.sprite.weapon.animation.seek(0)
