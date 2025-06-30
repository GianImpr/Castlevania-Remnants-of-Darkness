extends State
class_name UneDying
@export var dying_effect: PackedScene
var explosion

func enter():
	explosion = dying_effect.instantiate()
	get_parent().get_parent().add_child(explosion)
	explosion.scale = Vector2(0.5, 0.5)
	player.velocity = Vector2(0, 0)
	player.sprite.visible = false
	player.hitbox.monitoring = false
	
func Update(delta: float):
	if not explosion and not sound.playing:
		player.queue_free()


func Physics_Update(delta: float):
	pass
