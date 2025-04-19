extends State
class_name AxeArmorDeath
@export var hitbox_iframe: CollisionShape2D
var anim_state: int = 0

func enter():
	animation.play("dying_1", -1, 1)
	animation.speed_scale = 1.6
	player.velocity.x = 0
	hitbox_iframe.set_deferred("disabled", true)
	
func Update(delta: float):
	if not animation.is_playing():
		anim_state += 1
		match anim_state:
			1:
				animation.play("dying_1", -1, 1)
			2:
				animation.play("dying_2", -1, 1)
				sound.play_sound_effect_from_library("dying")
			3:
				animation.play("dying_3", -1, 1)
			_:
				player.queue_free()
			
		
func Physics_Update(delta: float):
	pass
