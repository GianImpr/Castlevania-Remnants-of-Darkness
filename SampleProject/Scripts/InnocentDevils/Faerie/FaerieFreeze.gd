extends State
class_name FaerieFreeze
var period: int = 0
@export var timer: Timer

func enter():
	player.velocity = Vector2.ZERO
	animation.play("idle")
	timer.start()
	
func _on_timer_timeout() -> void:
	Transitioned.emit(self, "idle")
