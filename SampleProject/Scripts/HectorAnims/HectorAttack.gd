extends State
class_name HectorAttack
var can_perfect_guard: bool = true
@export var hector_hands: Sprite2D
const DEFAULT_HAND_FRAME: int = 6
const FIST_FOLLOW_UP_FROM_TIME: float = 0.25
static var getWeaponAttackSound: Callable
static var getHectorAttackSound: Callable
const WEAPON_ANIMATION_DELAY: float = 0.01
static var speed_multiplier: float = 1
const SPEED_INCREASE_AFTER_FIST: float = 0.05


func _ready():
	HectorWait.resumeAttackAnimation = resumeAttackAnimation

func enter():
	speed_multiplier = 1
	if attack_anim_suffix() == "_spear":
		hector_hands.frame = DEFAULT_HAND_FRAME
		hector_hands.visible = true
	if not player.resume_attack:
		animation.play("attack" + attack_anim_suffix(), -1, get_attack_speed())
	else:
		resumeAttackAnimation()
	
func exit():
	hector_hands.visible = false
	if player.sprite.weapon != null:
		player.sprite.weapon.stop()
	
func Update(delta: float):
	remove_momentum()
	
	if (animation.current_animation == "attack_fist" and (InputBuffer.is_action_press_buffered("circle") and not Input.is_action_pressed("crouch")) or animation.current_animation == "attack_fist_2"  and InputBuffer.is_action_press_buffered("attack")) and animation.current_animation_position >= FIST_FOLLOW_UP_FROM_TIME:
		var fist_number: String = "_2" if animation.current_animation == "attack_fist" else ""
		playAttackAnimation(fist_number)
		if Global.player.sprite.weapon != null:
			get_tree().create_timer(WEAPON_ANIMATION_DELAY).timeout.connect(playWeaponAnim)
		getWeaponAttackSound.call()
		getHectorAttackSound.call()
		speed_multiplier += SPEED_INCREASE_AFTER_FIST
		HectorUppercut.damage_multiplier = speed_multiplier
	elif (animation.current_animation == "attack_fist" or animation.current_animation == "attack_fist_2") and animation.current_animation_position >= FIST_FOLLOW_UP_FROM_TIME:
		if (Input.is_action_just_pressed("circle") and Input.is_action_pressed("crouch")):
			Transitioned.emit(self, "uppercut")
		run_without_start_anim(false)
		can_guard()
		can_perform("jump", true)
		can_perform("backdash", true)
		can_turn()
		can_pose()
	elif (animation.current_animation == "attack_fist" or animation.current_animation == "attack_fist_2"):
		can_guard()
	
	if player.stats.canApplySkill(Skill.Skills.EXECUTIONERS_HAND) and animation.current_animation_position > 0.6 and InputBuffer.is_action_press_buffered("attack"):
		animation.seek(0)
		if player.sprite.weapon.animation.is_playing():
			player.sprite.weapon.set_anim_pos(0)
		else:
			player.sprite.weapon.play()
		get_hector_attack_sound()
		enter()
	
func Physics_Update(delta: float):
	can_perform("backdash", true)
	can_fall(true)
	check_is_hurt()
	can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

#Continues the attack animation from where AirAttack left off
func resumeAttackAnimation() -> void:
	var old_anim_pos = animation.current_animation_position
	animation.play("attack" + attack_anim_suffix(), -1, get_attack_speed())
	animation.seek(old_anim_pos)
	if player.sprite.weapon != null:
		player.sprite.weapon.animation.play("swing")
		player.sprite.weapon.set_anim_pos(player.sprite.weapon.anim_position)
	player.resume_attack = false

func playWeaponAnim() -> void:
	Global.player.sprite.weapon.play(get_attack_speed())
	Global.player.sprite.weapon.animation.seek(0)
	
func playAttackAnimation(punch_number: String) -> void:
	var anim_speed = get_attack_speed()
	var anim_suffix = attack_anim_suffix()
	animation.play("attack" + anim_suffix + punch_number, -1, anim_speed * speed_multiplier)
	animation.seek(0)
