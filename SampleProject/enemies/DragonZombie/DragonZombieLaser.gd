extends State
class_name DragonZombieLaser
@export var red_spark: PackedScene
const RED_SPARK_OFFSET: Vector2 = Vector2(0,-80)
var phase: int

func enter():
	phase = 0
	animation.play("build_laser")
	var red_spark_node = red_spark.instantiate()
	red_spark_node.global_position += RED_SPARK_OFFSET
	player.add_child(red_spark_node)
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	
	if phase == 0 and not animation.is_playing():
		animation.play("laser")
		phase = 1
	elif phase == 1 and not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
