extends State
class_name ArmorLordMince
@export var mincemeat_hitbox: CollisionShape2D
@export var iframe_timer: Timer

func enter():
	animation.play("mincemeat")
	player.velocity.x = 0
	
func exit():
	iframe_timer.stop()
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
	if animation.current_animation_position >= 2.6 and animation.current_animation_position <= 10.4 and mincemeat_hitbox.disabled and iframe_timer.is_stopped():
		iframe_timer.start()
		
		
func Physics_Update(delta: float):
	enemy_can_die()


func _on_iframes_timeout() -> void:
	mincemeat_hitbox.disabled = false
