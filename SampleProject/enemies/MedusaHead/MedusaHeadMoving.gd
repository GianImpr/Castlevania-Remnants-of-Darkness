extends State
class_name MedusaHeadMoving
@export var SPEED: Vector2
@export_range(0, 2, 0.1) var SINUSOIDAL_MOVEMENT_DURATION: float
@export_range(0, 0.5, 0.01, "suffix:s") var TURN_AROUND_DELAY: float
var tween: Tween

func enter():
	get_tree().create_timer(TURN_AROUND_DELAY).timeout.connect(initialize_medusa)

	
func exit():
	tween.kill()

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass

func initialize_medusa() -> void:
	can_turnaround_with_scale()
	player.velocity = Vector2(SPEED.x * player.facing_position, SPEED.y)
	tween = get_tree().create_tween()
	tween.bind_node(player)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_loops(99)
	tween.tween_property(player, "velocity", Vector2(player.velocity.x, -SPEED.y), SINUSOIDAL_MOVEMENT_DURATION)
	tween.tween_property(player, "velocity", Vector2(player.velocity.x, SPEED.y), SINUSOIDAL_MOVEMENT_DURATION)
