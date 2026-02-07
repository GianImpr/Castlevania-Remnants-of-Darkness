extends State
class_name FrozenShadeIcicle
const DURATION: float = 2
@export var icicle_scene: PackedScene
const ICICLES_TO_GENERATE: int = 3

func enter():
	animation.play("idle")
	get_tree().create_timer(DURATION, false).timeout.connect(Transitioned.emit.bind(self, "idle"))
	generateIcicles()
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass

func generateIcicles() -> void:
	sound.play_sound_effect_from_library("icicles")
	for i in range(0, ICICLES_TO_GENERATE):
		var icicle = icicle_scene.instantiate()
		icicle.global_position = player.global_position
		icicle.stats.thrower_ATK = player.stats.ATK
		MetSys.get_current_room_instance().add_child(icicle)
