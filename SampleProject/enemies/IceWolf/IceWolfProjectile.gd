extends State
class_name IceWolfProjectile
@export var projectile_scene: PackedScene
const OFFSET: Vector2 = Vector2(0,-24)

func enter():
	can_turnaround_with_scale()
	animation.play("projectile")
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass

func generateProjectile() -> void:
	var projectile = projectile_scene.instantiate()
	sound.play_sound_effect_from_library("projectile")
	projectile.global_position.x = player.global_position.x+OFFSET.x*player.facing_position
	projectile.global_position.y = player.global_position.y+OFFSET.y
	projectile.direction = player.facing_position
	if projectile.direction == 1:
		projectile.sprite.scale.x *= -1
	projectile.stats.thrower_ATK = player.stats.ATK
	MetSys.get_current_room_instance().add_child(projectile)
