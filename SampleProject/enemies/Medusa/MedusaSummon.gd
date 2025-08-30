extends State
class_name MedusaSummon
@export var snake_scene: PackedScene
@export var snake_flying_random_velocity: Vector2
@export var snake_spawning_point: Vector2
@export var snake_timer: Timer
var SNAKES_TO_SUMMON: int = 20
var snakes_summoned: int

func enter():
	animation.play("summon")
	sound.play_sound_effect_from_library("serpents")
	snakes_summoned = 0
	snake_timer.start()
	if not snake_timer.timeout.is_connected(summonSnakes):
		snake_timer.timeout.connect(summonSnakes)
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
	
func summonSnakes() -> void:
	snakes_summoned += 1
	if snakes_summoned < SNAKES_TO_SUMMON:
		snake_timer.start()
	var snake = snake_scene.instantiate()
	MetSys.get_current_room_instance().add_child(snake)
	snake.global_position.x = snake_spawning_point.x * player.facing_position + player.global_position.x
	snake.global_position.y = snake_spawning_point.y + player.global_position.y
	snake.velocity = Vector2(randf_range(-snake_flying_random_velocity.x, snake_flying_random_velocity.x), snake_flying_random_velocity.y)
