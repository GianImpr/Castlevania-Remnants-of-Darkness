extends State
class_name CtulhuLanding
const LANDING_FRAME: int = 0

func enter():
	player.sprite.frame = LANDING_FRAME
	player.flying = false

func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if player.is_on_floor():
		sound.play_sound_effect_from_library("landing")
		Transitioned.emit(self, decideAction())

func Physics_Update(delta: float):
	pass

func decideAction() -> String:
	const actions: Array[String] = ["fireball", "swinging"]
	return actions[randi_range(0, actions.size()-1)]
