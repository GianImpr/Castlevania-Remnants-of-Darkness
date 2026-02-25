extends State
class_name IceWolfDash
const SPEED: float = 1200
const DURATION: float = 0.8
var acceleration_tween: Tween

func enter():
	animation.play("dash")
	sound.play_sound_effect_from_library("dash")
	player.velocity.x = SPEED*player.facing_position
	acceleration_tween = get_tree().create_tween()
	acceleration_tween.set_trans(Tween.TRANS_SINE)
	acceleration_tween.set_ease(Tween.EASE_OUT)
	acceleration_tween.tween_property(player, "velocity:x", 0, DURATION)
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
