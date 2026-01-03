extends Control
class_name TrainingMenu

@export var trainings: Array[TrainingMode]
@export var animation: AnimationPlayer
@export var training_room: PackedScene

func openMenu():
	animation.play("open")
	
func closeMenu():
	animation.play("close")
	
func startTraining():
	return
