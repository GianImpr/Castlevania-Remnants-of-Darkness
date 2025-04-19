extends State
class_name DullahanAppearing
@export var trail_scene: PackedScene
@export var sword_sprite: Sprite2D
@export var trail_timer: Timer

func enter():
	animation.play("appearing")
	trail_timer.start()
	
func exit():
	Global.player.unfreeze()
	
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "throw_head")
		
	if animation.current_animation_position >= 3.5 and not trail_timer.is_stopped():
		trail_timer.stop()
	
func _on_trail_frequency_timeout() -> void:
	var trail = trail_scene.instantiate()
	player.add_child(trail)
	trail.texture = sword_sprite.texture
	trail.vframes = sword_sprite.vframes
	trail.hframes = sword_sprite.hframes
	trail.global_position = sword_sprite.global_position
	trail.scale = Vector2(2.3, 2.3)
	trail.rotation_degrees = sword_sprite.rotation_degrees
	trail.show_behind_parent = true
