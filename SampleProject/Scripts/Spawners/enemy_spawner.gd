extends Node
class_name EnemySpawner
@export var enemy_to_spawn: PackedScene
@export_range(0.1, 10) var spawn_frequency_in_seconds: float
@export var min_pos_limits: Vector2
@export var max_pos_limits: Vector2
@export var min_distance_from_player: float = 80

func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = spawn_frequency_in_seconds
	timer.connect("timeout", spawn)
	timer.start()

func spawn() -> void:
	var enemy = enemy_to_spawn.instantiate()
	enemy.position = Vector2(randf_range(min_pos_limits.x, max_pos_limits.x), randf_range(min_pos_limits.y, max_pos_limits.y))
	if abs(enemy.global_position.x - Global.player.global_position.x) < min_distance_from_player:
		if (enemy.global_position.x - min_distance_from_player) >= min_pos_limits:
			enemy.global_position.x -= min_distance_from_player
		elif (enemy.global_position.x + min_distance_from_player) < min_pos_limits:
			enemy.global_position.x += min_distance_from_player
	get_parent().add_child(enemy)
