extends State
class_name MedusaDying
@export var medusa_statue_scene: PackedScene

func enter():
	animation.play("die")
	sound.play_sound_effect_from_library("dead")
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass

func explode() -> void:
	var medusa_statue = medusa_statue_scene.instantiate()
	medusa_statue.global_position = player.global_position
	MetSys.get_current_room_instance().add_child(medusa_statue)
	player.visible = false
