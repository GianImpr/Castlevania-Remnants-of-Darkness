extends State
class_name KamikazeRavenPreparing
@export var SPEED: Vector2
@export_range(0, 2, 0.1, "suffix:s") var DURATION: float
@export var red_spark_scene: PackedScene
var tween: Tween

func enter():
	animation.play("fly")
	player.velocity = Vector2(SPEED.x * player.facing_position * (-1), SPEED.y)
	tween = get_tree().create_tween()
	tween.bind_node(player)
	if Global.game.difficulty == Game.Difficulty.CRAZY:
		tween.tween_property(player, "velocity", Vector2(0, 0), DURATION/2)
	else:
		tween.tween_property(player, "velocity", Vector2(0, 0), DURATION)
	tween.finished.connect(func(): Transitioned.emit(self, "moving"))
	var red_spark = red_spark_scene.instantiate()
	player.add_child(red_spark)

func exit():
	if tween.is_running():
		tween.kill()

func Update(delta: float):
	can_turnaround_with_scale()
	enemy_can_die()
