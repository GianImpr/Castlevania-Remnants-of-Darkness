extends State
class_name ZombieDying
@export var hitbox_iframe: CollisionShape2D
@export var dying_scene: PackedScene
@export var dying_blood: CPUParticles2D
const FREE_AFTER_SECONDS: float = 1.5
const OFFSET: Vector2 = Vector2(45,23)

func enter():
	animation.stop()
	player.hitbox_iframe.get_child(0).set_deferred("disabled", true)
	var dying_anim = dying_scene.instantiate()
	dying_anim.global_position = player.global_position
	dying_anim.global_position += OFFSET
	dying_anim.facing_position = player.direction
	if player.direction == 1:
		dying_anim.turnAround()
	MetSys.get_current_room_instance().add_child(dying_anim)
	player.sprite.visible = false
	dying_blood.emitting = true
	dying_blood.direction.x = player.direction * (-1)
	get_tree().create_timer(FREE_AFTER_SECONDS, false).timeout.connect(player.queue_free)
	
func Update(delta: float):
	pass
		
func Physics_Update(delta: float):
	pass
