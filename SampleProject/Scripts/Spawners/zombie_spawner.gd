extends Node
@export var enemy_to_spawn: PackedScene
@export var spawn_cooldown: Timer

func _ready() -> void:
	randomize()
	
func _on_spawn_interval_timeout() -> void:
	var enemy = enemy_to_spawn.instantiate()
	enemy.position = Vector2(randf_range(200, 2200), 392)
	enemy.direction = randi_range(-1, 1)
	if enemy.direction == 0:
		enemy.direction = -1
	if enemy.direction == -1:
		enemy.sprite.flip_h = true
	get_parent().add_child(enemy)
