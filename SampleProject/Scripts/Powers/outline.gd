extends Sprite2D
class_name Outline
@export var animation: AnimationPlayer
const DEFAULT_COLOR: Color = Color(1.0, 0.231, 0.243)

func _ready() -> void:
	frame = Global.player.sprite.frame
	flip_h = Global.player.sprite.flip_h

func play(color: Color = DEFAULT_COLOR) -> void:
	modulate = color
	animation.play("play")
	
func playBackwards(color: Color = DEFAULT_COLOR) -> void:
	modulate = color
	animation.play("play_back")
