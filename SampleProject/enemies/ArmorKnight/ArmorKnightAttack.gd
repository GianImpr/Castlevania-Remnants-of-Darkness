extends State
class_name ArmorKnightAttack
@export var thrust_speed: float

func enter():
	animation.play("attack", -1, 1)
	can_turnaround_with_scale()
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, decide_action())
		
func Physics_Update(delta: float):
	enemy_can_die()

func decide_action():
	var moves = ["deflect", "attack", "special", "ready"]
	return moves[randi_range(0, moves.size()-1)]

func apply_thrust_speed():
	var tween = get_tree().create_tween()
	player.velocity.x = thrust_speed * player.facing_position
	tween.tween_property(player, "velocity", Vector2(0, 0), 0.7)
