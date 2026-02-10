extends State
class_name DarkOctopusDying
@export var explosion_scene: PackedScene
@export var head_animation: AnimationPlayer
const ANIM_SPEED_SCALE: float = 2
const EXPLOSION_OFFSET: Vector2 = Vector2(0, 15)

func enter():
	head_animation.stop()
	animation.play("dying")
	player.velocity.x = 0
	animation.speed_scale = ANIM_SPEED_SCALE
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass
	
func generateExplosion():
	sound.play_sound_effect_from_library("dying")
	var explosion = explosion_scene.instantiate()
	explosion.global_position = player.global_position+EXPLOSION_OFFSET
	MetSys.get_current_room_instance().add_child(explosion)
