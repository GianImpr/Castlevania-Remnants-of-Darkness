extends State
class_name CtulhuJumping
const JUMP_FRAME: int = 87
@export var jump_strength: Vector2
var jumped: bool

func enter():
	player.flying = false
	jumped = false
	animation.play("start_flying")
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing() and not jumped:
		jump()
	elif jumped and player.is_on_floor():
		sound.play_sound_effect_from_library("landing")
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass

func jump() -> void:
	jumped = true
	player.velocity = Vector2(jump_strength.x * player.facing_position, jump_strength.y)
