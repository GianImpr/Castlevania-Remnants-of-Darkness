extends State
class_name HectorDamageKnockback
@export var recoil_speed: Vector2
@export var ignore_landing: Timer
var can_perfect_guard: bool = false
static var applyMercyInvincibility: Callable

func enter():
	player.velocity.x = recoil_speed.x * player.facing_position * (-1)
	player.velocity.y = recoil_speed.y
	ignore_landing.start()
	animation.play("damage_mercy")
	
func exit():
	if Global.game != null and Global.game.difficulty == Game.Difficulty.SIMPLIFIED:
		applyMercyInvincibility.call()
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_die()
	if player.is_on_floor():
		Transitioned.emit(self, "hard_landing")
