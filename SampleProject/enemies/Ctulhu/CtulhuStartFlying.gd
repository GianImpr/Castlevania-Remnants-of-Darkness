extends State
class_name CtulhuStartFlying
@export var jump_strength: float
@export_range(0, 1, 0.1, "suffix:s") var jump_duration: float
var tween: Tween

func enter():
	player.velocity.x = 0
	animation.play("start_flying")
	
func exit():
	if tween != null and tween.is_running():
		tween.kill()

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing():
		player.velocity.y = -jump_strength
		player.flying = true
		tween = get_tree().create_tween()
		tween.tween_property(player, "velocity", Vector2(0,0), jump_duration)
		tween.finished.connect(func(): Transitioned.emit(self, "flying"))

func Physics_Update(delta: float):
	pass
