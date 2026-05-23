extends State
class_name LizardmanIdle
const IDLE_FRAME: int = 148
var can_act: bool
var MIN_DURATION: float = 0.2
var MAX_DURATION: float = 0.5
var phase: int = 0
const OFFENSIVE_RANGE: int = 150

func enter():
	if player.activated_AI:
		animation.stop()
		player.sprite.frame = IDLE_FRAME
		can_act = false
		get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(Transitioned.emit.bind(self, decideAction()))
	else:
		animation.play("idle")
		phase = 0
	
func exit():
	pass

func Update(delta: float):
	can_turnaround_with_scale()
	
	if player.activated_AI and player.sprite.frame != IDLE_FRAME:
		animation.play("ready")
		phase = 1
	
	if not animation.is_playing() and phase == 1:
		phase = 2
		Transitioned.emit(self, decideAction())
	
	enemy_can_die()
	enemy_can_guard(player.should_guard or Global.player.isAttacking() and horizontal_distance_from_player() <= player.protective_area.get_child(0).shape.radius)

func Physics_Update(delta: float):
	pass
	
func decideAction() -> String:
	if horizontal_distance_from_player() <= OFFENSIVE_RANGE:
		return ["swing", "spit", "dash", "walkback"].pick_random()
	return ["walkforward", "dash"].pick_random()
