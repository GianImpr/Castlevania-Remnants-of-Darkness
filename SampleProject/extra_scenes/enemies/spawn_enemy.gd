#THIS NODE MUST BE USED UNDER A NODE THAT CONTAINS ALL ENEMIES IN THE ROOM
extends Node2D
class_name SpawnEnemy

@export var enemy: PackedScene
@export var enemy_type: String
@export var spawn_instantly: bool
@export var offset: Vector2
@export var spawn_range: Vector2
@export_category("Respawning")
@export var respawn: bool
@export_range(0, 30, 0.1, "suffix:s") var respawn_cooldown: float = 1
@export_category("Condition")
@export var condition: Conditions
@export var enemy_count: int
@export var max_at_once: int
@export_category("Nodes")
@export var timer: Timer
@export var animation: AnimationPlayer
var summoned_enemies: int = 0
var starting_pos: Vector2
@export var delete_timer: Timer

enum Conditions {
	ALWAYS,
	TOTAL_ENEMIES_LESS_THAN,
	SAME_ENEMY_TYPE_LESS_THAN,
	SUMMONED_IN_TOTAL,
	PUZZLE_SOLVED
}

func _ready():
	if Global.game.disable_lights:
		get_child(0).amount /= 10
	starting_pos = global_position
	if spawn_instantly:
		_playSpawn()
	timer.wait_time = respawn_cooldown
	timer.one_shot = not respawn
	timer.start()
	
func _process(delta: float) -> void:
	if checkSummonedEnemies() >= enemy_count and condition == Conditions.SUMMONED_IN_TOTAL and delete_timer.is_stopped():
		delete_timer.start()
	
func checkCondition(cond_type: Conditions):
	match cond_type:
		Conditions.ALWAYS:
			return true
		Conditions.TOTAL_ENEMIES_LESS_THAN:
			return checkAllEnemies() <= enemy_count
		Conditions.SUMMONED_IN_TOTAL:
			return checkSummonedEnemies() < enemy_count and checkSameTypeEnemies() < max_at_once

func _playSpawn():
	if condition == Conditions.SUMMONED_IN_TOTAL:
		if checkCondition(condition):
			global_position = starting_pos + Vector2(randf_range(-spawn_range.x/2, spawn_range.x/2), randf_range(-spawn_range.y/2, spawn_range.y/2))
			if global_position.x > Global.player.global_position.x - 50 and global_position.x < Global.player.global_position.x + 50 and spawn_range.x != 0 and spawn_range.y != 0:
				var modify_pos = (randf_range(50,100)*sign(randi_range(0,1)*2-1))
				global_position.x += modify_pos
			animation.play("spawn")
	elif checkCondition(condition):
		animation.play("spawn")

func _spawnEnemy():
	summoned_enemies += 1
	var enemy_node = enemy.instantiate()
	get_parent().add_child(enemy_node)
	enemy_node.global_position = global_position - offset  
	if "activated_AI" in enemy_node:
		enemy_node.activated_AI = true
	enemy_node.modulate = Color(1, 0, 1, 0)
	enemy_node.process_mode = Node.PROCESS_MODE_DISABLED
	var tween = get_tree().create_tween()
	tween.tween_property(enemy_node, "modulate", Color(1, 0, 1, 0.5), 0.5)
	await tween.finished
	tween = get_tree().create_tween()
	tween.tween_property(enemy_node, "modulate", Color(1, 1, 1, 1), 0.5)
	await tween.finished
	enemy_node.process_mode = Node.PROCESS_MODE_INHERIT

func deleteIfNoRespawn():
	if not respawn:
		queue_free()
		
func checkAllEnemies():
	var enemy_number: int
	for child in get_parent().get_children():
		if child is Enemy:
			enemy_number += 1
	return enemy_number
	
func checkSameTypeEnemies():
	var enemy_number: int
	for child in get_parent().get_children():
		if child is Enemy and child.get_name() == enemy_type:
			enemy_number += 1
	return enemy_number
	
func checkSummonedEnemies():
	return summoned_enemies


func _on_delete_timer_timeout() -> void:
	queue_free()
