extends State
class_name SlaughtererMoving
@export var JUMP_SPEED: Vector2
var current_phase: Phase
enum Phase {
	IDLE,
	JUMPING,
	FALLING,
	LANDING
}

func enter():
	current_phase = Phase.IDLE
	animation.play("jump")
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing() and current_phase == Phase.IDLE:
		player.velocity = JUMP_SPEED
		player.velocity.x *= player.facing_position
		current_phase = Phase.JUMPING
		
	if player.velocity.y > 0:
		current_phase = Phase.FALLING
		
	if current_phase == Phase.FALLING and player.is_on_floor():
		player.velocity.x = 0
		animation.play("land")
		current_phase = Phase.LANDING
		
	if current_phase == Phase.LANDING and not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
