extends CombatScene
@export var armor_lord: PackedScene
var spawned_lord: bool = false
@export var spawn_enemy: PackedScene
var spawn

	
func _process(delta: float) -> void:
	var spawns_left = 0
	var enemies_left = 0
	for child in get_children():
		if child is SpawnEnemy:
			spawns_left += 1
	for child in get_children():
		if child.get_name() == "ArmorLord":
			spawned_lord = true
		if child is Enemy:
			enemies_left += 1
	if spawns_left == 0 and not spawned_lord:
		spawn = spawn_enemy.instantiate()
		spawn.enemy = armor_lord
		spawn.enemy_type = "ArmorLord"
		spawn.spawn_instantly = false
		spawn.respawn_cooldown = 3
		spawn.offset.y = 113
		spawn.global_position = Vector2(450, 420)
		spawn.spawn_range = Vector2(700, 0)
		spawn.condition = spawn.Conditions.SUMMONED_IN_TOTAL
		spawn.respawn = true
		spawn.enemy_count = 2
		spawn.max_at_once = 2
		spawn.max_at_once = 1
		spawn.respawn_cooldown = 1
		add_child(spawn)
	if enemies_left == 0 and spawned_lord and spawns_left == 0 and not Global.player.stats.combat_flags[event_ID]:
		Global.player.stats.combat_flags[event_ID] = true
		_dissolveMusic()
		


func _on_timer_timeout() -> void:
	playMusic("encounter")
