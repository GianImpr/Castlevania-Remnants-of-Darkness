extends Sprite2D
class_name WeaponSprite
@export var animation: AnimationPlayer
@export var hitbox: PlayerHitbox
var facing_position: int = 1
var anim_position: float

func ready():
	visible = false

func play():
	visible = true
	animation.play("swing")
	
func play_air():
	visible = true
	animation.play("swing_air")

func stop():
	visible = false
	animation.stop()
	
func register_anim_pos():
	anim_position = animation.current_animation_position
	
func set_anim_pos(seconds: float):
	animation.seek(seconds)

func flip():
	facing_position *= -1
	scale.x *= -1
