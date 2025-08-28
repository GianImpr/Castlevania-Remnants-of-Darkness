extends State
class_name MedusaBeam
@export var red_spark_scene: PackedScene

func enter():
	animation.play("laser")
	var red_spark = red_spark_scene.instantiate()
	player.add_child(red_spark)
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass

func shootBeam() -> void:
	pass
