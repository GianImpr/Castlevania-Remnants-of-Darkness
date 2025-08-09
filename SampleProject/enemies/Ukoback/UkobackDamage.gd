extends State
class_name UkobackDamage

const DECELERATION_DURATION: float = 0.3

func enter():
	animation.play("damage")
	sound.play_sound_effect_from_library("damage")
	get_tree().create_tween().tween_property(player, "velocity", Vector2.ZERO, DECELERATION_DURATION)
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing():
		Transitioned.emit(self, "moving")

func Physics_Update(delta: float):
	pass
