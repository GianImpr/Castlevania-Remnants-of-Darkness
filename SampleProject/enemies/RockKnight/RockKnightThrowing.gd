extends State
class_name RockKnightThrowing
@export var rock_scene: PackedScene
@export var red_spark_scene: PackedScene
const ROCK_SPEED_MULTIPLIER: float = 0.48
const OFFSET: Vector2 = Vector2(22,-72)

func enter():
	animation.play("throwing")
	var red_spark = red_spark_scene.instantiate()
	player.add_child(red_spark)
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
	enemy_can_die()

func Physics_Update(delta: float):
	pass

func throwRock() -> void:
	voice.play_sound_effect_from_library(["throw_1", "throw_2"].pick_random())
	var rock = rock_scene.instantiate()
	rock.global_position.x = player.global_position.x+OFFSET.x*player.facing_position
	rock.global_position.y = player.global_position.y+OFFSET.y
	rock.SPEED.x = abs(Global.player.global_position.x - player.global_position.x) * player.facing_position * ROCK_SPEED_MULTIPLIER
	rock.facing_position = player.facing_position
	rock.stats.thrower_ATK = player.stats.ATK
	MetSys.get_current_room_instance().add_child(rock)
