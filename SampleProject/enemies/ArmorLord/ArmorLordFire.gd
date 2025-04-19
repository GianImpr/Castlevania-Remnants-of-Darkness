extends State
class_name ArmorLordFire
@export var fire_hitbox: CollisionShape2D

func enter():
	animation.play("fire_attack")
	player.velocity.x = 0
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
		
func Physics_Update(delta: float):
	enemy_can_die()
