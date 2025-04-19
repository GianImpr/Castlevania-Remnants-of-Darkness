extends State
class_name BatFlying
@export var hitbox_iframe: CollisionShape2D
@export var SPEED: Vector2

func enter():
	if Global.player.global_position.x > player.global_position.x:
		player.facing_position = 1
		player.sprite.flip_h = true
	else:
		player.facing_position = -1
		player.sprite.flip_h = false
	
	player.velocity.y = SPEED.y 
	animation.play("flying", -1, 1)
	
func Update(delta: float):
	pass
		
func Physics_Update(delta: float):
	player.velocity.x = SPEED.x * player.facing_position
	player.velocity.y = SPEED.y * pow(sin(player.position.x*delta), 2) * sign(sin(player.position.x*delta))
	
	enemy_can_die()
		
func _on_area_of_vision_body_entered(body: Node2D) -> void:
	player.activated_AI = true

func isHigherThanPlayer() -> bool:
	return Global.player.position.y > player.position.y
	
func trackPlayerHeight() -> int:
	if isHigherThanPlayer():
		return 1
	else:
		return -1
