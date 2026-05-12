extends State
class_name GhostDying
@export var hitbox: CollisionShape2D
@export var dying_effect: PackedScene

func enter():
	animation.play("dead")
	sound.play_sound_effect_from_library("dying")
	hitbox.set_deferred("disabled", true)
	var explosion = dying_effect.instantiate()
	get_parent().get_parent().add_child(explosion)
	player.velocity = Vector2(0, 0)
	
func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass
