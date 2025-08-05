extends State
class_name BlackCrowMoving
@export var MAX_SPEED:  float
@export_range(0, 5, 0.1, "suffix: s") var flight_duration: float
@export_range(0, 5, 0.1, "suffix: s") var flight_duration_variation: float
@export var altitude_random_offset: float

var tween: Tween

func enter():
	var actual_flight_duration = flight_duration + randf_range(-flight_duration_variation, flight_duration_variation)
	var velocity_y: float =  (Global.player.global_position.y - player.global_position.y) * 2.5 + randf_range(-altitude_random_offset, altitude_random_offset*3)
	player.velocity.x = MAX_SPEED * player.facing_position
	player.velocity.y = velocity_y
	tween = get_tree().create_tween()
	tween.tween_property(player, "velocity", Vector2(player.velocity.x, 0), actual_flight_duration/2)
	tween.tween_property(player, "velocity", Vector2(player.velocity.x, -velocity_y), actual_flight_duration/2)
	tween.finished.connect(on_tween_finished)
	
func exit():
	if tween.is_running():
		tween.kill()
	
func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass

func on_tween_finished() -> void:
	Transitioned.emit(self, "idle")
