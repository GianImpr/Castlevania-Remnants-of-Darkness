extends Sprite2D
class_name WeaponSprite
@export var animation: AnimationPlayer
@export var hitbox: PlayerHitbox
@export var has_parent_node: bool = false
var facing_position: int = 1
var anim_position: float

func ready():
	visible = false

func play(anim_speed: float = 1):
	animation.play("swing", -1, anim_speed)

	
func play_air(anim_speed: float = 1):
	animation.play("swing_air", -1, anim_speed)
	visible = true
	
func play_crouch(anim_speed: float = 1, visible_from_start: bool = true):
	animation.play("swing_crouch", -1, anim_speed)
	visible = visible_from_start


func stop():
	visible = false
	animation.call_deferred("stop")
	
func register_anim_pos():
	anim_position = animation.current_animation_position
	
func set_anim_pos(seconds: float):
	animation.seek(seconds)

func flip():
	facing_position *= -1
	if has_parent_node:
		get_parent().scale.x *= -1
	else:
		scale.x *= -1
