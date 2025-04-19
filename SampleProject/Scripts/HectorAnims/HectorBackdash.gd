extends State
class_name HectorBackdash
@export var backdash_speed: float
@export var trail_scene: PackedScene
@export var debris_scene: PackedScene
@export var trail_timer: Timer
@export var debris_timer: Timer
var can_perfect_guard: bool = true


func instance_scene(scene: PackedScene, get_player_frame: bool, offset: Vector2):
	var instance: Sprite2D = scene.instantiate()
	get_parent().get_parent().get_parent().add_child(instance)
	instance.scale = player.scale
	instance.global_position = player.global_position + offset
	instance.flip_h = player.sprite.flip_h
	if get_player_frame:
		instance.frame = player.sprite.frame
		instance.texture = player.sprite.texture
		instance.hframes = player.sprite.hframes
		instance.vframes = player.sprite.vframes

func enter():
	animation.play("run_end", -1, -1, true)
	animation.seek(0.5)
	player.velocity.x = backdash_speed * player.facing_position * (-1)
	sound.play_sound_effect_from_library("backdash")
	instance_scene(trail_scene, true, Vector2(0,0))
	instance_scene(debris_scene, false, Vector2(player.facing_position*40,68))
	trail_timer.start()
	debris_timer.start()
	if randi_range(0, 1) > 0:
		voice.play_sound_effect_from_library("Backdash")
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_perform("jump", true)
	can_perform("crouch", false)
	can_fall(true)
	check_is_hurt()
	can_guard()
	can_die()
	if player.is_on_wall():
		debris_timer.stop()
		
	if animation.is_playing():
		player.velocity.x *= 0.9
	else:
		player.velocity.x = 0
		Transitioned.emit(self, "idle")
		
func exit():
	trail_timer.stop()
	debris_timer.stop()

func _on_trail_timer_timeout() -> void:
	instance_scene(trail_scene, true, Vector2(0,0))
	
func _on_debris_timer_timeout() -> void:
	instance_scene(debris_scene, false, Vector2(player.facing_position*40,68))
