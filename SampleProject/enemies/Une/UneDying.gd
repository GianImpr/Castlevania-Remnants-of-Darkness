extends State
class_name UneDying
@export var dying_effect: PackedScene
var explosion

func enter():
	explosion = dying_effect.instantiate()
	explosion.global_position = player.global_position - Vector2(0,10)
	MetSys.get_current_room_instance().add_child(explosion)
	player.velocity = Vector2(0, 0)
	player.sprite.visible = false
	player.hitbox.monitoring = false
	
func Update(delta: float):
	if not explosion and not sound.playing and not player.blood_particles.emitting:
		player.queue_free()


func Physics_Update(delta: float):
	pass
