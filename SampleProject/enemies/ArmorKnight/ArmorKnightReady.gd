extends State
class_name ArmorKnightReady
@export var walk_speed: float
@export var horizontal_sight_spear: float
@export var vertical_distance_spear: float
@export var distance_vision: float
var walk_direction: int
const Moves = {
	DEFLECT = "deflect",
	ATTACK = "attack",
	SPECIAL = "special",
	READY = "ready",
	SWING_UP = "swingUp",
	SWING_DOWN = "swingDown"
}

func enter():
	animation.play("walk_ready", -1, 1)
	player.velocity.x = 0
	can_turnaround_with_scale()
	walk_direction = randi_range(0, 1)*2-1
	
func Update(delta: float):
	if animation.current_animation_position >= 0.1 and animation.current_animation_position < 0.5:
		player.velocity.x = walk_speed * walk_direction
	elif not animation.is_playing():
		player.velocity.x = 0
		Transitioned.emit(self, decide_action())
		
	if player.deflect_projectile:
		Transitioned.emit(self, "deflect")
		
func Physics_Update(delta: float):
	enemy_can_die()

func decide_action():
	if is_above_player_within_range(horizontal_sight_spear, vertical_distance_spear):
		return Moves.SWING_DOWN
	if is_below_player_within_range(horizontal_sight_spear, vertical_distance_spear):
		return Moves.SWING_UP
	
	var dif = abs(player.global_position - Global.player.global_position)
	if dif.x > distance_vision or dif.y > 50:
		return Moves.READY
	
	return Moves.keys()[randi_range(1, Moves.size()-3)]
