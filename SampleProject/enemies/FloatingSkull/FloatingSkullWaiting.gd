extends State
class_name FloatingSkullWaiting
@export var SPEED: Vector2

func enter():
	if Global.game.difficulty == Game.Difficulty.CRAZY:
		animation.speed_scale = 3
	animation.play("idle")
	
func Update(delta: float):
	player.velocity = SPEED * player.facing_position
	can_turnaround_with_scale()
	if player.activated_AI:
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
