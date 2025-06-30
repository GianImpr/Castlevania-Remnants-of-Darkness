extends State
class_name BansheeMoving
@export var speed: float
@export var move_duration: Timer

func enter():
	animation.play("moving", -1, 1)
	move_duration.start()
	
func Update(delta: float):
	can_turnaround()
	enemy_can_die()

func Physics_Update(delta: float):
	var cur_speed = Vector2(speed * player.facing_position, speed/5)
	if is_below_player():
		cur_speed.y = speed/5 * (-1)
		
	player.velocity = cur_speed
	
	if abs(player.global_position.x - Global.player.global_position.x) < 10 and abs(player.global_position.y - Global.player.global_position.y) < 25:
		Transitioned.emit(self, "preparing")
		move_duration.stop()

func _on_duration_timeout() -> void:
	Transitioned.emit(self, "preparing")
