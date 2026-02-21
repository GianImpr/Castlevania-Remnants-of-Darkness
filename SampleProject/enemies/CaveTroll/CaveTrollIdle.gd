extends State
class_name CaveTrollIdle

const MIN_DURATION: float = 0.2
const MAX_DURATION: float = 0.6
var can_act: bool
const TONGUE_DISTANCE: float = 170
var should_jump: bool = true

func enter():
	can_act = false
	animation.play("idle")
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(func(): can_act = true)
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	if sign(player.facing_position) != sign(Global.player.global_position.x - player.global_position.x):
		Transitioned.emit(self, "turning")
		print_orphan_nodes()
		return
	
	if player.activated_AI and can_act:
		Transitioned.emit(self, decideAction())

func Physics_Update(delta: float):
	pass

func decideAction() -> String:
	if horizontal_distance_from_player() <= TONGUE_DISTANCE and not should_jump:
		return ["tongue", "magic", "jumpings"].pick_random()
	should_jump = false
	return "jumping"
