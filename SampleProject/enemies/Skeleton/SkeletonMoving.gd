extends State
class_name SkeletonMoving
@export var hitbox_iframe = CollisionShape2D
@export var timer_attack: Timer
@export var timer_direction: Timer
@export var SPEED: float
@export var aggro_distance: Vector2
var time_to_attack: bool = false

func enter():
	animation.play("walk", -1, 1)
	timer_attack.start()
	timer_direction.start()
	
func Update(delta: float):
	pass
		
		
func Physics_Update(delta: float):
	player.velocity.x = SPEED * player.direction * delta
	
	if Global.player.global_position.x > player.global_position.x:
		player.facing_position = 1
		player.sprite.flip_h = true
	else:
		player.facing_position = -1
		player.sprite.flip_h = false
		
	if can_attack():
		time_to_attack = false
		Transitioned.emit(self, "attack")
	
	enemy_can_die()
		
func can_attack() -> bool:
	return abs(player.global_position - Global.player.global_position) < aggro_distance and time_to_attack


func _on_switch_direction_timeout() -> void:
	if abs(player.global_position - Global.player.global_position) < aggro_distance:
		player.direction = player.direction * (-1)
	else:
		player.direction = player.facing_position
	timer_direction.wait_time = randf_range(0.5, 1)
		
func _on_attack_timeout() -> void:
	time_to_attack = true
	if Global.game.difficulty == Global.game.Difficulty.CRAZY:
		timer_attack.wait_time = randf_range(0.5, 1.7)
	else:
		timer_attack.wait_time = randf_range(0.5, 2)
