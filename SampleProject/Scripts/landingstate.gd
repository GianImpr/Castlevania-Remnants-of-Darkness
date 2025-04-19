extends State

class_name LandingState

@export var ground_state: State

#Ground state after landing animation is done
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "landing":
		next_state = ground_state

func on_enter():
	playback.play("landing")

func state_process(delta):
	if character.direction != 0:
		next_state = ground_state
		playback.play("run")
