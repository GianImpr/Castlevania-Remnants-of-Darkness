extends State
class_name HectorUppercut
var can_perfect_guard: bool = false
const CANCELABLE_FROM: float = 0.4
static var thunder_version: bool = false
static var applyMercyInvincibility: Callable
@export var uppercut_effects: Node2D
const LIGHT_2D_CHILD_INDEX: int = 2
const UPPERCUT_EFFECTS_POSITION: float = 12

func enter():
	if thunder_version:
		animation.play("thunder_uppercut")
		applyMercyInvincibility.call()
		uppercut_effects.position.x = UPPERCUT_EFFECTS_POSITION * player.facing_position
		
	else:
		animation.play("uppercut")
	remove_momentum()
	
func exit():
	thunder_version = false
	uppercut_effects.get_child(LIGHT_2D_CHILD_INDEX).energy = 0

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	can_perform("backdash", true)
	can_fall(true)
	check_is_hurt()
	can_die()
	
	if Input.is_action_just_pressed("attack") and Input.is_action_pressed("guard") and animation.current_animation_position >= CANCELABLE_FROM:
		animation.seek(0)
	
	if not animation.is_playing():
		if Input.is_action_pressed("guard"):
			Transitioned.emit(self, "guard")
		else:
			Transitioned.emit(self, "idle")

func shakeCamera() -> void:
	Global.camera.apply_shake()
