extends State
class_name BoneScimitarMoving
@export var hitbox_iframe = CollisionShape2D
@export var timer_attack: Timer
@export var timer_direction: Timer
@export var SPEED: float
var time_to_attack: bool = false

func enter():
	animation.play("moving", -1, 1)
	timer_attack.start()
	timer_direction.start()
	
func Update(delta: float):
	pass
		
		
func Physics_Update(delta: float):
	player.velocity.x = SPEED * player.direction * delta
	
	if Global.player.global_position.x > player.global_position.x and player.facing_position == -1:
		player.facing_position = 1
		turn_around()
	elif Global.player.global_position.x < player.global_position.x and player.facing_position == 1:
		player.facing_position = -1
		turn_around()
		
	if can_attack():
		time_to_attack = false
		Transitioned.emit(self, "attack")
	
	enemy_can_die()
		
func can_attack() -> bool:
	return abs(player.global_position - Global.player.global_position) < Vector2(80, 30) and time_to_attack

		
func _on_attack_timeout() -> void:
	time_to_attack = true
	timer_attack.wait_time = randf_range(0.5, 1)


func _on_change_direction_timeout() -> void:
	if abs(player.global_position - Global.player.global_position) < Vector2(80, 30):
		player.direction = player.direction * (-1)
	else:
		player.direction = player.facing_position
	timer_direction.wait_time = randf_range(0.5, 1)
	
func turn_around():
	player.scale.x *= (-1)
