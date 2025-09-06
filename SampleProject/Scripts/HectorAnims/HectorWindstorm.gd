extends State
class_name HectorWindstorm
var can_perfect_guard: bool = false
@export var windstorm_scene: PackedScene
@export var windstorm_spawning_offset: Vector2

func enter():
	animation.play("windstorm")
	player.playSpecialAttackEffect()
	var windstorm = windstorm_scene.instantiate()
	windstorm.scale.x *= player.facing_position
	windstorm.global_position = player.global_position
	windstorm.global_position.x += (windstorm_spawning_offset.x * player.facing_position)
	windstorm.global_position.y += windstorm_spawning_offset.y
	MetSys.get_current_room_instance().add_child(windstorm)
	remove_momentum()
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	can_fall(true)
	check_is_hurt()
	can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
