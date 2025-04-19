extends State
class_name BonePillarIdle
@export var idle_duration: Timer

func enter():
	animation.play("idle", -1, 1.5)
	if player.activated_AI:
		idle_duration.wait_time = randf_range(0.7, 1.5)
		idle_duration.start()

func Update(delta):
	if player.facing_position == -1 and not in_front_of_player() or player.facing_position == 1 and in_front_of_player():
		Transitioned.emit(self, "turning")

	enemy_can_die(false)
	

func _on_vision_body_entered(body: Node2D) -> void:
	player.activated_AI = true
	idle_duration.start()

func _on_idle_duration_timeout() -> void:
	idle_duration.stop()
	Transitioned.emit(self, "shoot")
