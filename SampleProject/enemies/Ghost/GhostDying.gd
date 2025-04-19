extends State
class_name GhostDying
@export var area: Area2D
@export var dying_effect: PackedScene

func enter():
	animation.play("dead")
	sound.play_sound_effect_from_library("dying")
	area.monitoring = false
	var explosion = dying_effect.instantiate()
	get_parent().get_parent().add_child(explosion)
	player.velocity = Vector2(0, 0)
	
func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass
