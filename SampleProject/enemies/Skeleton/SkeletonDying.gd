extends State
class_name SkeletonDying
@export var hitbox_iframe: CollisionShape2D
@export var dying_scene: PackedScene

func enter():
	player.velocity.x = 0
	player.hitbox_iframe.set_deferred("disabled", true)
	
func Update(delta: float):
	pass
		
func Physics_Update(delta: float):
	var dying_anim = dying_scene.instantiate()
	dying_anim.global_position = player.global_position
	dying_anim.facing_position = player.facing_position
	get_parent().get_parent().get_parent().add_child(dying_anim)
	player.queue_free()
		
