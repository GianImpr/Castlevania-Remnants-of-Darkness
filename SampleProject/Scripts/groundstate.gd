extends State

class_name GroundState

@export var JUMP_VELOCITY = -700.0
@export var air_state: State

func state_process(delta):
	if not character.is_on_floor():
		next_state = air_state

func state_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		jump()
	else:
		playback.play("idle")
		
func jump():
	character.velocity.y = JUMP_VELOCITY
	sfx.set_stream(load("res://assets/sounds/jump.MP3"))
	sfx.play()
	next_state = air_state
	playback.play("jump")
