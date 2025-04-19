extends State
class_name AxeArmorRespawnAxe
@export var hitbox_iframe: CollisionShape2D

func enter():
	animation.play("respawn_axe", -1, 1)
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "moving")
		
func Physics_Update(delta: float):
	enemy_can_die()
