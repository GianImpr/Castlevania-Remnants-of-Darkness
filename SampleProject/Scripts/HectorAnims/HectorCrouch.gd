extends State
class_name HectorCrouch
@export var slide_after_timer: Timer
var can_perfect_guard: bool = false
var can_slide: bool
var slide_pressed: bool
const CROUCHED_FRAME_POS: float = 0.4

func enter():
	if not slide_after_timer.timeout.is_connected(canSlide):
		slide_after_timer.timeout.connect(canSlide)
	can_slide = false
	slide_pressed = false
	animation.play("crouch", -1, 2.9)
	if player.skip_crouch_anim:
		animation.seek(CROUCHED_FRAME_POS)
		player.skip_crouch_anim = false
	player.velocity.x = 0
	
func exit():
	slide_after_timer.stop()

func Update(delta: float):
	if not Input.is_action_pressed("crouch") and not slide_pressed:
		Transitioned.emit(self, "rise")
		
	if slide_pressed and (can_slide or player.direction != 0):
		Transitioned.emit(self, "slide")
		
	if Input.is_action_just_pressed("jump"):
		slide_pressed = true
		slide_after_timer.start()
		
	can_turn()
	can_fall(false)
	can_attack()
	can_guard()
	check_is_hurt()
	can_die()
	can_drop_ledge()
	player.canCreateAquariusTrap()

func canSlide() -> void:
	can_slide = true
	
