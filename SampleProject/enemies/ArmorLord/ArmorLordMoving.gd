extends State
class_name ArmorLordMoving
@export var SPEED: Vector2
@export var duration_timer: Timer

func enter():
	animation.play("step")
	if Global.game.difficulty == Global.game.Difficulty.CRAZY:
		duration_timer.wait_time = 0.3
	player.velocity = SPEED * player.direction * (randi_range(0, 1)*2-1)
	duration_timer.start()

func Update(delta: float):
	pass
		
func Physics_Update(delta: float):
	enemy_can_die()
	
func _on_duration_timeout() -> void:
	Transitioned.emit(self, "idle")
