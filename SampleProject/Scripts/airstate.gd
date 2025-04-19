extends State

class_name AirState

@export var landing_state: State

func state_process(delta):
	if character.is_on_floor():
		next_state = landing_state
	
	if Input.is_action_just_released("jump") and character.velocity.y < 0:
		character.velocity.y *= 0.95*delta
