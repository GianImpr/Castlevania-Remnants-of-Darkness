extends State
class_name CrowDismiss

func enter():
	animation.stop()
	player.velocity = Vector2.ZERO
	if player.is_alive:
		player.vanishing_particles.emitting = true
		await player.vanishing_particles.finished
	Global.player.innocent_devil_scene = null
	player.queue_free()
