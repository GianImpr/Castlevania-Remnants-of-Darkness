extends State
class_name HectorSwordSpin
@export var sword_spin: Node2D
@export var sword_spin_hitbox: CollisionShape2D
@export var sheathe_sound: PolyphonicAudio
var can_perfect_guard: bool = false
var transitioned_to_sheathe: bool

func enter():
	transitioned_to_sheathe = false
	player.playSpecialAttackEffect()
	animation.play("sword_throw", -1, 1.1)
	player.sprite.weapon.animation.play("boomerang", -1, 1.1)

func exit():
	sword_spin.visible = false
	sword_spin_hitbox.disabled = true

	player.sprite.weapon.sheathe.visible = false
	player.sprite.weapon.animation.stop()

	if player.sprite.weapon.boomerang:
		player.sprite.weapon.boomerang.visible = false

	if animation.current_animation == "sheathe_sword_rt":
		sheathe_sound.stop()


func Update(delta: float):
	can_perform("backdash", true)
	can_fall(true)
	check_is_hurt()
	
	if animation.current_animation == "sheathe_sword_rt":
		if InputBuffer.is_action_press_buffered("jump"):
			Transitioned.emit(self, "jump")
		else:
			can_attack()
			run_without_start_anim(false)
			can_guard()
			can_perform("backdash", true)
			can_perform("crouch", false)
			can_turn()
			can_pose()
	
	if not animation.is_playing():
		if not transitioned_to_sheathe:
			playSheatheAnimation()
		else:
			Transitioned.emit(self, "idle")

	
func Physics_Update(delta: float):
	remove_momentum()

func playSheatheAnimation() -> void:
	if player.sprite.weapon.boomerang:
		player.sprite.weapon.boomerang.visible = false
		
	transitioned_to_sheathe = true
	animation.play("sheathe_sword_rt")
	player.sprite.weapon.play_sheathe(WeaponSprite.SheatheType.ROUND_TRIP)
