extends State
class_name RockKnightDying
@export var hitbox_iframe: CollisionShape2D
@export var dying_scene: PackedScene

func enter():
	player.hitbox_iframe.set_deferred("disabled", true)
	
func Update(delta: float):
	pass
		
func Physics_Update(delta: float):
	var dying_anim = dying_scene.instantiate()
	dying_anim.global_position = player.global_position
	dying_anim.facing_position = player.facing_position
	if player.facing_position == 1:
		dying_anim.turnAround()
	get_parent().get_parent().get_parent().add_child(dying_anim)
	player.queue_free()
