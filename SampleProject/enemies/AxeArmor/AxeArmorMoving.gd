extends State
class_name AxeArmorMoving

@export var hitbox_iframe: CollisionShape2D
@export var SPEED: float

func enter():
	animation.play("walk", -1, 1)
	
func Update(delta: float):
	if can_attack():
		Transitioned.emit(self, "attack")
		
		
func Physics_Update(delta: float):
	player.velocity.x = SPEED * player.facing_position * delta * int(player.is_moving)
	
	if not in_front_of_player():
		player.facing_position = 1
		player.sprite.flip_h = true
	else:
		player.facing_position = -1
		player.sprite.flip_h = false
	
	enemy_can_die()
		
func can_attack() -> bool:
	return abs(player.global_position - Global.player.global_position) < Vector2(300, 50)
	
func taking_step():
	sound.play_sound_effect_from_library("step")
