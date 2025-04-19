extends State
class_name FaerieFreeze
@export var wings: AnimationPlayer
var period: int = 0
@export var timer: Timer
@export var glow: PointLight2D

func enter():
	glow.visible = false
	animation.play("idle")
	wings.play("normal")
	timer.start()
	
func exit():
	glow.visible = true

func _on_timer_timeout() -> void:
	Transitioned.emit(self, "idle")
