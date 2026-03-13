extends State
class_name DarkOctopusInk
const SPEED: float = 60
var MIN_OFFSET: Vector2 = Vector2(-80, 0)
var MAX_OFFSET: Vector2 = Vector2(80, 50)
const MIN_DURATION: float = 3
const MAX_DURATION: float = 4
const ANIM_SPEED_SCALE: float = 2
const DEFAULT_SPEED_SCALE: float = 1
const INK_AMOUNT: int = 5
@export var ink_scene: PackedScene
@export var ink_timer: Timer
@export var ink_sound_timer: Timer

func enter():
	if not ink_timer.timeout.is_connected(createInk):
		ink_timer.timeout.connect(createInk)
		ink_sound_timer.timeout.connect(sound.play_sound_effect_from_library.bind("ink"))

	sound.play_sound_effect_from_library("start_ink")
	animation.speed_scale = ANIM_SPEED_SCALE
	ink_timer.start()
	ink_sound_timer.start()
	player.velocity.x = 0
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(Transitioned.emit.bind(self, "idle"))
	
func exit():
	animation.speed_scale = DEFAULT_SPEED_SCALE
	ink_timer.stop()
	ink_sound_timer.stop()


func Update(delta: float):
	if player.velocity.x > 0:
		player.velocity.x = 0
	enemy_can_die()

func Physics_Update(delta: float):
	pass

func createInk() -> void:
	for i in range(0, INK_AMOUNT):
		var ink = ink_scene.instantiate()
		var offset_x: float = randf_range(MIN_OFFSET.x, MAX_OFFSET.x)
		var offset_y: float = randf_range(MIN_OFFSET.y, MAX_OFFSET.y)
		ink.global_position = player.global_position + Vector2(offset_x, offset_y)
		ink.stats.thrower_ATK = player.stats.ATK
		ink.z_index = player.z_index+1
		MetSys.get_current_room_instance().add_child(ink)
