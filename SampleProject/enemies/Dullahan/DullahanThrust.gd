extends State
class_name DullahanThrust
@export var thrust_speed: float
var rng: int

func enter():
	animation.play("thrust")
	player.velocity.x = 0
	rng = randi_range(0, 99)
	can_turnaround_with_scale()
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
		
	if player.phase_two and rng < 80 and animation.current_animation_position >= 1.4 and not player.isCorneringPlayer():
		animation.seek(0.4)
		rng = 80
		

func apply_thrust_speed():
	var tween = get_tree().create_tween()
	player.velocity.x = thrust_speed * player.facing_position
	tween.tween_property(player, "velocity", Vector2(0, 0), 0.7)
