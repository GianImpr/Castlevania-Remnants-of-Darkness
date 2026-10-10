extends State
class_name HectorCrouchAttack
var can_perfect_guard: bool = true
const FIST_ANIMATION_CANCELLABLE_FROM: float = 0.48
static var getWeaponAttackSound: Callable
static var getHectorAttackSound: Callable
const WEAPON_ANIMATION_DELAY: float = 0.01
@export var hector_hands: Sprite2D
@export var sheathe_sound: PolyphonicAudio
@export var slide_after_timer: Timer
const DEFAULT_HAND_FRAME: int = 6
var should_transition_to_sheathe: bool
var transitioned_to_sheathe: bool
var can_slide: bool
var slide_pressed: bool


func enter():
	playAttackAnimation()
	can_slide = false
	slide_pressed = false
	transitioned_to_sheathe = false
	should_transition_to_sheathe = Global.player.stats.getCurrentWeaponType() == Weapon.Type.SWORD
	if not slide_after_timer.timeout.is_connected(canSlide):
		slide_after_timer.timeout.connect(canSlide)

func exit():
	if player.sprite.weapon != null:
		player.sprite.weapon.stop()
	hector_hands.visible = false
	slide_after_timer.stop()
	
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

	if animation.current_animation == "sheathe_sword_crouch":
		if InputBuffer.is_action_press_buffered("attack"):
			sheathe_sound.stop()
			can_turn()
			player.sprite.weapon.sheathe.visible = false
			playWeaponAnim()
			get_hector_attack_sound()
			transitioned_to_sheathe = false
			enter()
		else:
			if Input.is_action_just_pressed("jump"):
				slide_pressed = true
				slide_after_timer.start()
				
			if not Input.is_action_pressed("crouch") and not slide_pressed:
				Transitioned.emit(self, "rise")
				
			if slide_pressed and (can_slide or player.direction != 0):
				Transitioned.emit(self, "slide")
				return
				
			can_turn()
			can_guard()
			can_drop_ledge()
			player.canCreateAquariusTrap()



	if not animation.is_playing():
		if should_transition_to_sheathe and not transitioned_to_sheathe:
			playSheatheAnimation()
		else:
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

func playSheatheAnimation() -> void:
	transitioned_to_sheathe = true
	animation.play("sheathe_sword_crouch")
	player.sprite.weapon.play_sheathe(WeaponSprite.SheatheType.CROUCH)

func canSlide() -> void:
	can_slide = true
