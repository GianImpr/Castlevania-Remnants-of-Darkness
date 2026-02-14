extends State
class_name DeadPirateDying
@export var hitbox_iframe: CollisionShape2D
@export var dying_scene: PackedScene
@export var dying_blood: CPUParticles2D
const FREE_AFTER_SECONDS: float = 1.5

func enter():
	animation.stop()
	player.anti_air.get_child(0).set_deferred("disabled", true)
	player.sword.get_child(0).set_deferred("disabled", true)
	player.hitbox_iframe.get_child(0).set_deferred("disabled", true)
	var dying_anim = dying_scene.instantiate()
	dying_anim.global_position = player.global_position
	dying_anim.facing_position = player.facing_position
	if player.facing_position == 1:
		dying_anim.turnAround()
	get_parent().get_parent().get_parent().add_child(dying_anim)
	player.sprite.visible = false
	dying_blood.emitting = true
	dying_blood.direction.x = player.facing_position
	get_tree().create_timer(FREE_AFTER_SECONDS, false).timeout.connect(player.queue_free)
	
func Update(delta: float):
	pass
		
func Physics_Update(delta: float):
	pass
