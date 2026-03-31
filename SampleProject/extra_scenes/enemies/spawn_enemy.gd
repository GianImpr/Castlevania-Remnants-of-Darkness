#THIS NODE MUST BE USED UNDER A NODE THAT CONTAINS ALL ENEMIES IN THE ROOM
extends Node2D
class_name SpawnEnemy

@export var enemy: PackedScene
@export var enemy_type: String
@export var spawn_instantly: bool
@export var LV_bonus: int = 0
@export var offset: Vector2
@export var automatic_offset: bool = false
@export var spawn_range: Vector2
@export var activate_behavior_instantly: bool = true
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
@export var particles: GPUParticles2D

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
		Conditions.SAME_ENEMY_TYPE_LESS_THAN:
			return checkSameTypeEnemies() < max_at_once

func _playSpawn():
	if condition == Conditions.SUMMONED_IN_TOTAL:
		if checkCondition(condition):
			if particles.emitting:
				await particles.finished
			var previous_position: float = global_position.x
			var spawn_range_offset: Vector2 = Vector2(randf_range(-spawn_range.x/2, spawn_range.x/2), randf_range(-spawn_range.y/2, spawn_range.y/2))
			if starting_pos.x+spawn_range_offset.x > Global.player.global_position.x - 120 and starting_pos.x+spawn_range_offset.x < Global.player.global_position.x + 120 and (spawn_range.x != 0 or spawn_range.y != 0):
				var modify_pos = (randf_range(120,150)*sign(starting_pos.x+spawn_range_offset.x - Global.player.global_position.x))
				spawn_range_offset.x += modify_pos
				spawn_range_offset.x = min(max(-spawn_range.x/2, spawn_range_offset.x), spawn_range.x/2)
			global_position = starting_pos + spawn_range_offset
			animation.play("spawn")

	elif checkCondition(condition):
		if particles.emitting:
			await particles.finished
		animation.play("spawn")

func _spawnEnemy():
	summoned_enemies += 1
	var enemy_node = enemy.instantiate()
	enemy_node.stats.LV += LV_bonus
	enemy_node.stats.ATK += LV_bonus * 2.5
	enemy_node.global_position = global_position - offset
	get_parent().add_child(enemy_node)
	var hurtbox: CollisionShape2D
	for child in enemy_node.get_children():
		if child is CollisionShape2D:
			hurtbox = child
			break
	if hurtbox and automatic_offset:
		enemy_node.global_position = Vector2(global_position.x, global_position.y - (hurtbox.position.y + hurtbox.shape.size.y/2)*hurtbox.global_scale.y)
	if "activated_AI" in enemy_node:
		enemy_node.activated_AI = activate_behavior_instantly
	elif "ai_activated" in enemy_node:
		enemy_node.ai_activated = activate_behavior_instantly
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
		if child is Enemy and child.stats.enemy_name == enemy_type:
			enemy_number += 1
	return enemy_number
	
func checkSummonedEnemies():
	return summoned_enemies


func _on_delete_timer_timeout() -> void:
	queue_free()
