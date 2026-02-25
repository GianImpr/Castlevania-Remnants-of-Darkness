extends State
class_name IceWolfCharge
@export var red_spark_scene: PackedScene

func enter():
	var red_spark = red_spark_scene.instantiate()
	red_spark.global_position = player.global_position
	MetSys.get_current_room_instance().add_child(red_spark)
	animation.play("charge")
	can_turnaround_with_scale()
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing():
		Transitioned.emit(self, "dash")

func Physics_Update(delta: float):
	pass
