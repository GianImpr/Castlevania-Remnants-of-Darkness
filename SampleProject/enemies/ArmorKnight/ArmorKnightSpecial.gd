extends State
class_name ArmorKnightSpecial
@export var swing_speed: float
@export var red_spark_scene: PackedScene

func enter():
	animation.play("special_attack", -1, 1)
	can_turnaround_with_scale()
	var red_spark = red_spark_scene.instantiate()
	player.add_child(red_spark)
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, decide_action())
		
func Physics_Update(delta: float):
	enemy_can_die()

func decide_action():
	var moves = ["deflect", "attack", "special", "ready"]
	return moves[randi_range(0, moves.size()-1)]

func apply_swing_speed():
	var tween = get_tree().create_tween()
	player.velocity.x = swing_speed * player.facing_position
	tween.tween_property(player, "velocity", Vector2(0, 0), 0.4)
