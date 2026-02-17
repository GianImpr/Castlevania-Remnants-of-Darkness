extends State
class_name LizardmanSwing
@export var trail: Sprite2D
@export var sword_hitbox: CollisionShape2D
const TRAIL_DEFAULT_FRAME = 170

func enter():
	player.dash_attacking = false
	player.velocity.x = 0
	animation.play("swing")
	
func exit():
	trail.frame = TRAIL_DEFAULT_FRAME
	sword_hitbox.set_deferred("disabled", true)

func Update(delta: float):
	enemy_can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
