extends State
class_name HectorDamage
@export var blood: CPUParticles2D
var can_perfect_guard: bool = false
static var applyMercyInvincibility: Callable

func enter():
	if player.hurt_from_back:
		animation.play("hurt_back", -1, 1.2)
	else:
		animation.play("hurt", -1, 1.2)
	player.hurt_from_back = false
	player.velocity.x = 0
	blood.emitting = true
	
func exit():
	if Global.game != null and Global.game.difficulty == Game.Difficulty.SIMPLIFIED:
		applyMercyInvincibility.call()
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
		player.is_hurt = false
	
	
	can_fall(false)
	can_die()
