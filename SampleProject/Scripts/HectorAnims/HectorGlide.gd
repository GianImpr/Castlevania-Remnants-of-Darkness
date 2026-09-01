extends State
class_name HectorGlide
const JUMP_VELOCITY: float = -700
const GLIDING_VELOCITY: float = 200
const FALL_STARTING_ANIM_TIME: float = 0.5
var can_perfect_guard: bool = false
var jumped: bool
static var interrupted: bool = false

func enter():
	player.is_hurt = false
	interrupted = false
	if player.is_on_floor():
		player.velocity.x = 0
		animation.play("jump", -1, 1.7)
		animation.seek(0)
		player.velocity.y = JUMP_VELOCITY
		sound.play_sound_effect_from_library("jump")
		await animation.animation_finished
		if player.state_machine.current_state == self:
			player.velocity.x = GLIDING_VELOCITY*player.facing_position
	else:
		player.velocity.x = GLIDING_VELOCITY*player.facing_position
		animation.play("jump", -1, 1.3)
		animation.seek(FALL_STARTING_ANIM_TIME)

func exit():
	interrupted = true

func Physics_Update(delta: float):
	if player.velocity.y > 0:
		player.velocity.y *= 0.3
		
	if (InputBuffer.is_action_press_buffered("jump") or player.is_on_wall()) and player.velocity.y > 0:
		interrupted = true
	
	if (Global.player.innocent_devil is not Crow):
		interrupted = true
	
	if interrupted:
		can_fall(false)
		
	can_land()
	can_die()
	check_is_hurt()
