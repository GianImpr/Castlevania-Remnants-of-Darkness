extends State
class_name LizardmanSpit
@export var spit_hitbox: CollisionPolygon2D
@export var spit_particles: CPUParticles2D

func enter():
	animation.play("spit")
	
func exit():
	spit_hitbox.set_deferred("disabled", true)
	spit_particles.emitting = false

func Update(delta: float):
	enemy_can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
		
	enemy_can_guard(player.should_guard)

func Physics_Update(delta: float):
	pass
