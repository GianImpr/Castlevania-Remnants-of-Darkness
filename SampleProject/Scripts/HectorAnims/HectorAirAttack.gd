extends State
class_name HectorAirAttack
var can_perfect_guard: bool = true
const HEIGHT_DECELERATION: float = 0.95
@export var hector_hands: Sprite2D
const DEFAULT_HAND_FRAME: int = 6

func enter():
	var anim_suffix: String = attack_anim_suffix()
	if anim_suffix == "_spear":
		hector_hands.frame = DEFAULT_HAND_FRAME
		hector_hands.visible = true
	elif anim_suffix == "_fist" and Input.is_action_pressed("crouch"):
		anim_suffix = "_fist_diag"
	animation.play("air_attack" + anim_suffix, -1, get_attack_speed())
	
func exit():
	if player.sprite.weapon != null and not player.resume_attack and not player.state_machine.new_state is HectorWait:
		player.sprite.weapon.stop()
	elif player.sprite.weapon != null and player.resume_attack:
		player.sprite.weapon.register_anim_pos()
	hector_hands.visible = false
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	if Input.is_action_just_released("jump") and player.velocity.y < 0:
		player.velocity.y *= HEIGHT_DECELERATION*delta
		
	can_move_with_momentum(false)
	check_is_hurt()
	can_land()
	can_die()
	
	if not animation.is_playing() and not player.is_on_floor():
		Transitioned.emit(self, "falling")
