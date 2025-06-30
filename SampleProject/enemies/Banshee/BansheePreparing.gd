extends State
class_name BansheePreparing
@export var red_spark: PackedScene

func enter():
	player.velocity = Vector2(0, 0)
	animation.play("preparing", -1, 1)
	var red_spark_scene = red_spark.instantiate()
	player.add_child(red_spark_scene)
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "yelling")
	
	enemy_can_die()

func Physics_Update(delta: float):
	pass
