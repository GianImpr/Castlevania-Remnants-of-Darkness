extends State
class_name BatDying
@export var dying_effect: PackedScene
var explosion

func enter():
	sound.play_sound_effect_from_library("dead")
	explosion = dying_effect.instantiate()
	get_parent().get_parent().add_child(explosion)
	player.velocity = Vector2(0, 0)
	player.sprite.visible = false
	player.hitbox.monitoring = false
	
func Update(delta: float):
	if not explosion and not sound.playing:
		player.queue_free()


func Physics_Update(delta: float):
	pass
