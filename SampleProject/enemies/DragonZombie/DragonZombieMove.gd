extends State
class_name DragonZombieMove
const MIN_DURATION: float = 0.5
const MAX_DURATION: float = 1
const CAMERA_SHAKE_STRENGTH: int = 5
var direction: int
const SPEED: float = 70

func enter():
	direction = [-1,1].pick_random()
	
	if abs(player.global_position.x - Global.camera.limit_left) < player.MINIMUM_DISTANCE:
		direction = 1
		
	if direction == 1:
		animation.play_backwards("walk_backwards")
	else:
		animation.play("walk")
	player.velocity.x = SPEED*direction
	get_tree().create_timer(randf_range(MIN_DURATION, MAX_DURATION), false).timeout.connect(Transitioned.emit.bind(self, decideAction()))
	
func exit():
	player.velocity.x = 0

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass

func decideAction() -> String:
	if abs(player.global_position.x - Global.camera.limit_left) < player.MINIMUM_DISTANCE:
		return "move"
	return ["breath", "laser", "bite"].pick_random()

func shakeCamera() -> void:
	Global.camera.random_strength = CAMERA_SHAKE_STRENGTH
	Global.camera.apply_shake()
