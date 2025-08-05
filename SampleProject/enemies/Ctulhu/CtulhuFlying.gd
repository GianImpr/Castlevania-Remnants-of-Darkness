extends State
class_name CtulhuFlying
@export var SPEED: float
@export_range(0, 2, 0.1, "suffix:s") var flight_duration: float
@export_range(0, 2, 0.1, "suffix:s") var random_flight_duration_offset: float
@export var flight_timer: Timer

func _ready() -> void:
	flight_timer.timeout.connect(func(): Transitioned.emit(self, decideActionInAir()))


func enter():
	animation.play("flying")
	flight_timer.wait_time = flight_duration + random_flight_duration_offset
	flight_timer.start()
	
func exit():
	flight_timer.stop()

func Update(delta: float):
	player.velocity.x = SPEED * player.facing_position
	enemy_can_die()

func Physics_Update(delta: float):
	pass

func decideActionInAir() -> String:
	const actions: Array[String] = ["landing", "air_fireball"]
	return actions[randi_range(0, actions.size()-1)]
