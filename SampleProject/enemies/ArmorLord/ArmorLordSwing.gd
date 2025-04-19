extends State
class_name ArmorLordSwing
@export var forward_momentum: float
var advancing: bool

func enter():
	animation.play("swing_sword")
	advancing = false
	
func Update(delta: float):
	if animation.current_animation_position >= 1.1 and not advancing:
		player.velocity.x = forward_momentum * player.facing_position
		var tween = get_tree().create_tween()
		tween.tween_property(player, "velocity", Vector2(0, 0), 0.2)
		
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
		
func Physics_Update(delta: float):
	enemy_can_die()
