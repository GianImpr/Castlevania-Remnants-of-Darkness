extends State
class_name HectorDamage
@export var blood: CPUParticles2D
var can_perfect_guard: bool = false


func enter():
	animation.play("hurt", -1, 1.2)
	player.velocity.x = 0
	blood.emitting = true
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
		player.is_hurt = false
		
	can_fall(false)
	can_die()
