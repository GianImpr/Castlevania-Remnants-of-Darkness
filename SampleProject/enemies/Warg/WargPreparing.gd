extends State
class_name WargPreparing
@export_range(0, 3, 0.1, "suffix:s") var ANIM_DURATION: float

func enter():
	player.velocity.x = 0
	animation.play("preparing")
	get_tree().create_timer(ANIM_DURATION).timeout.connect(secondPhasePreparation)
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass

func secondPhasePreparation():
	if player.stats.HP <= 0:
		return
	animation.play("targeting")
	sound.play_sound_effect_from_library("growl")
	get_tree().create_timer(ANIM_DURATION).timeout.connect(func(): if player.stats.HP > 0: Transitioned.emit(self, "biting"))
	
