extends State
class_name DullahanDying
var phase: int = 0
@export var explosion_scene: PackedScene
@export var dullahan_sprite: Sprite2D
@export var head_disappear: Timer
@export var queue_free_timer: Timer
@export var head_sound: PolyphonicAudio

func enter():
	animation.play("throw_head")
	dullahan_sprite.material.set_shader_parameter("enabled", false)

	
func exit():
	pass
	
func Update(delta: float):
	if not animation.is_playing() and phase == 0:
		animation.play("dying")
		phase = 1
	
	if not animation.is_playing() and phase == 1:
		var explosion = explosion_scene.instantiate()
		head_sound.play_sound_effect_from_library("dying")
		explosion.global_position = player.head_sprite.global_position
		#explosion.scale = Vector2(2, 2)
		player.get_parent().get_parent().add_child(explosion)
		head_disappear.start()
		queue_free_timer.start()
		phase = 2


func _on_head_disappear_delay_timeout() -> void:
	player.head_sprite.visible = false


func _on_free_delay_timeout() -> void:
	player.queue_free()
