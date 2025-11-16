extends State
class_name MedusaStoneCircle
@export var stone_circle_scene: PackedScene

func enter():
	animation.play("magic")
	sound.play_sound_effect_from_library("damn")
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, ["dash", "beam"].pick_random())
		
	if animation.is_playing() and animation.current_animation_position > 6.5 and player.stats.HP < player.max_HP / 2:
		Transitioned.emit(self, "summon")

func Physics_Update(delta: float):
	pass

func summonStoneCircle() -> void:
	var stone_circle = stone_circle_scene.instantiate()
	player.add_child(stone_circle)
