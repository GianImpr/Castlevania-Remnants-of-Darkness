extends Node2D
class_name BreakableWall
@export var breaking_particles: CPUParticles2D
@export var wall: DestructibleBody2D
@export var sound: PolyphonicAudio
@export var pick_up_flag: int
@export var collision_box: CollisionShape2D
@export var item_scene: PackedScene
const HITS_TO_TAKE: int = 3
var hits_taken: int = 0
var broken: bool = false

func takeDamage() -> void:
	hits_taken += 1
	if breaking_particles.emitting:
		breaking_particles.preprocess = 0.2
		breaking_particles.restart()
	else:
		breaking_particles.preprocess = 0
		
	breaking_particles.emitting = true

	if hits_taken < HITS_TO_TAKE:

		sound.play_sound_effect_from_library("damage")
	else:
		broken = true
		collision_box.set_deferred("disabled", true)
		wall.detonate()
		var item = item_scene.instantiate()
		item.z_index = 10
		item.pickup_flag = pick_up_flag
		item.set_deferred("global_position", global_position)
		MetSys.get_current_room_instance().call_deferred("add_child", item)
		sound.play_sound_effect_from_library("break")
