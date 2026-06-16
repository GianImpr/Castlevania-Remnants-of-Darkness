extends Node2D
class_name BreakableWall
@export var breaking_particles: CPUParticles2D
@export var wall: DestructibleBody2D
@export var sound: PolyphonicAudio
@export var pick_up_flag: int
@export var wall_flag: int
@export var collision_box: CollisionShape2D
@export var item_scene: PackedScene
@export var type: PickUp.ItemType
@export var id: int
const HITS_TO_TAKE: int = 3
var hits_taken: int = 0
var broken: bool = false

func _ready() -> void:
	if Global.player.stats.wall_flags[wall_flag]:
		queue_free()

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
		if item_scene:
			var item = item_scene.instantiate()
			if item is PickUp:
				item.type = type
				item.id = id
			item.z_index = 10
			item.pickup_flag = pick_up_flag
			item.set_deferred("global_position", global_position)
			item.picked.connect(func(): Global.player.stats.wall_flags[wall_flag] = true)
			MetSys.get_current_room_instance().call_deferred("add_child", item)
		else:
			Global.player.stats.wall_flags[wall_flag] = true
		sound.play_sound_effect_from_library("break")
