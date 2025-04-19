extends State
class_name ArmorLordIdle
@export var duration_timer: Timer

func enter():
	animation.play("idle")
	if Global.game.difficulty == Global.game.Difficulty.CRAZY:
		duration_timer.wait_time = 0.2
	player.velocity.x = 0
	if player.activated_AI:
		duration_timer.start()
	if Global.player.global_position.x > player.global_position.x and player.facing_position == -1:
		player.facing_position = 1
		turn_around()
	elif Global.player.global_position.x < player.global_position.x and player.facing_position == 1:
		player.facing_position = -1
		turn_around()
	
func Update(delta: float):
	if player.activated_AI and duration_timer.is_stopped():
		duration_timer.start()
		player.vision.set_deferred("disabled", true)
		
func Physics_Update(delta: float):
	enemy_can_die()
		
func _on_area_of_vision_body_entered(body: Node2D) -> void:
	player.activated_AI = true


func _on_duration_timeout() -> void:
	var states = ["moving", "swing", "fire", "mince"]
	Transitioned.emit(self, states[randi_range(0,3)])

func turn_around():
	player.scale.x *= (-1)
