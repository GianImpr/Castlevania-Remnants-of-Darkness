extends Node
@export var flag_id: int
@export var enemy_to_spawn: PackedScene

func _ready():
	if Global.player.stats.hint_flags[flag_id]:
		queue_free()

func _process(delta: float) -> void:
	if Global.player.stats.hint_flags[flag_id]:
		spawnEnemy()
		queue_free()
		
func spawnEnemy():
	var enemy = enemy_to_spawn.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = Vector2(Global.player.global_position.x+300, 426)
	enemy.direction = -1
	enemy.sprite.flip_h = true
