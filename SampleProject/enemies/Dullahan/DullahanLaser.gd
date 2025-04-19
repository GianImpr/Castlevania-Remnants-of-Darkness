extends State
class_name DullahanLaser
@export var red_spark_scene: PackedScene

func enter():
	animation.play("laser")
	can_turnaround_with_scale()
	var red_spark = red_spark_scene.instantiate()
	player.add_child(red_spark)
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
		
	if player.phase_two and animation.current_animation_position > 3.05:
		if Global.game.difficulty != Global.game.Difficulty.CRAZY:
			Transitioned.emit(self, "needles")
		else:
			Transitioned.emit(self, "thrust")
