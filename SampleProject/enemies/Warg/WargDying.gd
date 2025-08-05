extends State
class_name WargDying
@export var fire_pillar_scene: PackedScene
@export var fire_pillar_offset: float
@export var flame_pillar_timer: Timer
const FIRE_PILLAR_ORIGIN: Vector2 = Vector2(-20, 66)

func enter():
	player.velocity.x = 0
	animation.play("dying")
	flame_pillar_timer.timeout.connect(spawnFirePillar)
	flame_pillar_timer.start()
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass

func spawnFirePillar() -> void:
	var fire_pillar = fire_pillar_scene.instantiate()
	fire_pillar.global_position = player.global_position + FIRE_PILLAR_ORIGIN
	fire_pillar.global_position.x += randf_range(-fire_pillar_offset, fire_pillar_offset)
	fire_pillar.z_index = randi_range(1, 2)
	MetSys.get_current_room_instance().add_child(fire_pillar)
