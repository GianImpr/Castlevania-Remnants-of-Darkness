extends State
class_name CtulhuSwinging
@export var ice_wave_scene: PackedScene
@export var red_spark_scene: PackedScene

func enter():
	player.velocity.x = 0
	animation.play("swing")
	var red_spark = red_spark_scene.instantiate()
	player.add_child(red_spark)
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing():
		if Global.game.difficulty == Game.Difficulty.NORMAL:
			Transitioned.emit(self, "idle")
		else:
			Transitioned.emit(self, "fireball")
	
func Physics_Update(delta: float):
	pass

func generateIceWave() -> void:
	const SPAWN_POSITION_OFFSET: Vector2 = Vector2(-75, 0)
	const ICE_WAVE_SPEED: float = 800
	var ice_wave = ice_wave_scene.instantiate()
	MetSys.get_current_room_instance().add_child(ice_wave)
	ice_wave.stats.thrower_ATK = player.stats.ATK
	ice_wave.linear_velocity.x = ICE_WAVE_SPEED * player.facing_position
	ice_wave.global_position = player.global_position + SPAWN_POSITION_OFFSET*player.facing_position*(-1)
	ice_wave.direction = player.facing_position
	if player.facing_position == 1:
		ice_wave.sprite.scale.x *= -1
