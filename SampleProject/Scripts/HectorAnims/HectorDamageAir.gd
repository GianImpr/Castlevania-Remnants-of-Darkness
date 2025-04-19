extends State
class_name HectorDamageAir
@export var pushback: float
@export var blood: CPUParticles2D
var can_perfect_guard: bool = false


func enter():
	animation.play("hurt_air", -1, 1)
	blood.emitting = true
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	if player.velocity.y < 0:
		player.velocity.y *= 0.95*delta
	player.velocity.x = player.facing_position * (-1) * pushback
	can_die()
	
	if player.is_on_floor():
		Transitioned.emit(self, "hard_landing")
