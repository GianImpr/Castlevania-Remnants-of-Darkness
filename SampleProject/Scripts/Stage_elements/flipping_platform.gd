extends StaticBody2D
class_name FlippingPlatform
@export var area: Area2D
@export var animation: AnimationPlayer
var should_flip: bool = false

func _ready() -> void:
	area.body_entered.connect(func(body: Node2D): should_flip = true)
	area.body_exited.connect(func(body: Node2D): should_flip = false)
	
func _process(delta: float) -> void:
	if should_flip and Global.player.is_on_floor():
		flip()
	
func flip() -> void:
	if not animation.is_playing():
		animation.play("flipping")
