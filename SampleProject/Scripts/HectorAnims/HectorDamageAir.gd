extends State
class_name HectorDamageAir
@export var pushback: float
@export var blood: CPUParticles2D
var can_perfect_guard: bool = false
const HEIGHT_DECELERATION: float = 0.95
static var applyMercyInvincibility: Callable


func enter():
	animation.play("hurt_air", -1, 1)
	blood.emitting = true
	
func exit():
	if Global.game != null and Global.game.difficulty == Game.Difficulty.SIMPLIFIED:
		applyMercyInvincibility.call()
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	if player.velocity.y < 0:
		player.velocity.y *= HEIGHT_DECELERATION*delta
	player.velocity.x = player.facing_position * (-1) * pushback
	can_die()
	can_double_jump()
	
	if player.is_on_floor():
		Transitioned.emit(self, "hard_landing")
