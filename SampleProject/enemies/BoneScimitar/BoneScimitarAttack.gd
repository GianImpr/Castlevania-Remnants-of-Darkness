extends State
class_name BoneScimitarAttack
@export var hitbox_iframe: CollisionShape2D

func enter():
	animation.play("attack", -1, 1)
	player.velocity.x = 0
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "moving") 
		
func Physics_Update(delta: float):
	enemy_can_die()
