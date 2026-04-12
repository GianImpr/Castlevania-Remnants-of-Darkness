extends State
class_name CrowIdle
var period: int = 0
const MAX_DISTANCE: float = 100
const MAX_ATTACK_DISTANCE: float = 300
const BASE_SPEED: Vector2 = Vector2(5, 25)
const ANIMATION_OFFSET_MULTIPLIER: float = 1.5

func enter():
	var cur_anim_pos: float = 0
	if animation.current_animation == "moving":
		cur_anim_pos = animation.current_animation_position * ANIMATION_OFFSET_MULTIPLIER
	animation.play("idle")
	animation.seek(cur_anim_pos)
	
func Update(delta: float):
	var target_position: Vector2 = Global.player.position
	var distance_from_enemy: float
	if player.targeted_enemy != null and player.mode == InnocentDevil.Mode.OFFENSIVE:
		target_position = player.targeted_enemy.global_position
		distance_from_enemy = abs(Global.player.position - target_position).length_squared()
		if player.can_dash and distance_from_enemy <= Vector2(MAX_ATTACK_DISTANCE, MAX_ATTACK_DISTANCE).length_squared() and player.mode == InnocentDevil.Mode.OFFENSIVE:
			Transitioned.emit(self, "dash")
		elif distance_from_enemy > Vector2(MAX_ATTACK_DISTANCE, MAX_ATTACK_DISTANCE).length_squared():
			target_position = Global.player.position

	if abs(player.position - target_position).length_squared() > Vector2(MAX_DISTANCE, MAX_DISTANCE).length_squared():
		Transitioned.emit(self, "fly")
	innocent_can_guard()
	innocent_check_is_hurt("hurt")
	innocent_can_die()
	if player.can_glide or player.current_skill != InnocentDevil.Ability.GLIDE:
		can_use_skill()
	
func Physics_Update(delta: float):
	period = (period+1)%360
	var step = float(period)/360*PI*2
	player.velocity = Vector2(BASE_SPEED.x*sin(step), BASE_SPEED.y*cos(step))
