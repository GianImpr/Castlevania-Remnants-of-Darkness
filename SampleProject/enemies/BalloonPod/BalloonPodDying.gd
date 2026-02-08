extends State
class_name BalloonPodDying
@export var seed_scene: PackedScene
@export var seeds_to_spawn: int = 50

func enter():
	if not player.flying:
		animation.play("break")
	else:
		animation.play("break_flying")
	sound.play_sound_effect_from_library("break")
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass
	
func spawnSeeds() -> void:
	player.sprite.visible = false
	for i in range(0, seeds_to_spawn):
		var seed_projectile = seed_scene.instantiate()
		seed_projectile.global_position = player.global_position
		seed_projectile.stats.thrower_ATK = player.stats.ATK
		MetSys.get_current_room_instance().add_child(seed_projectile)
