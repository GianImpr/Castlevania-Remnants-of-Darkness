extends State
class_name HectorOpeningDoor
@export var run_timer: Timer
@export var idle_timer: Timer
@export var final_timer: Timer
var can_close: bool = false
var can_perfect_guard: bool = false


func enter():
	animation.play("run_end", -1, 1.5)
	idle_timer.start()
	player.velocity.x = 0
	can_close = false
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	if not animation.is_playing() and run_timer.is_stopped():
		animation.play("idle", -1, 0.65)
		
	if not animation.is_playing() and not run_timer.is_stopped():
		animation.play("run", -1, 1.5)

func _on_idle_duration_timeout() -> void:
	run_timer.start()
	animation.play("run_start", -1, 1.6)
	player.velocity.x = player.facing_position * player.SPEED

func _on_run_duration_timeout() -> void:
	animation.play("run_end", -1, 1.5)
	final_timer.start()
	can_close = true
	player.velocity.x = 0

func _on_final_duration_timeout() -> void:
	Transitioned.emit(self, "idle")
