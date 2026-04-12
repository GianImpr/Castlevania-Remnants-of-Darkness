extends State
class_name CrowFlying
const ANIMATION_SPEED_DIFF_FROM_IDLE: float = 0.6667
const FLY_FROM_DISTANCE: Vector2 = Vector2(250,250)
const MAX_DISTANCE: Vector2 = Vector2(100,100)
const MIN_HEIGHT_OFFSET: float = 100
const HORIZONTAL_OFFSET_FROM_TARGET: float = 100

var target_position: Vector2
var targeting_enemy: bool = false

func enter():
	target_position =  Global.player.position
	if player.targeted_enemy != null and abs(Global.player.position - target_position).length_squared() <= MAX_DISTANCE.length_squared():
		target_position = player.targeted_enemy.global_position
		targeting_enemy = true
		if "facing_position" in player.targeted_enemy:
			target_position.x += HORIZONTAL_OFFSET_FROM_TARGET*player.targeted_enemy.facing_position

	var cur_anim_pos: float = animation.current_animation_position * ANIMATION_SPEED_DIFF_FROM_IDLE
	animation.play("moving")
	animation.seek(cur_anim_pos)
	
func Update(delta: float):
	var distance_from_enemy: float
	if player.targeted_enemy != null:
		distance_from_enemy = abs(Global.player.position - target_position).length_squared()
		
	#if player.can_dash and player.targeted_enemy != null and targeting_enemy and distance_from_enemy <= MAX_DISTANCE.length_squared():
		#Transitioned.emit(self, "dash")
		#return
		
	if player.can_glide or player.current_skill != InnocentDevil.Ability.GLIDE:
		can_use_skill()

	if abs(player.position - target_position).length_squared() <= FLY_FROM_DISTANCE.length_squared() and not player.prepare_for_flight and not player.is_hurt:
		Transitioned.emit(self, "idle")
	elif player.prepare_for_flight:
		Transitioned.emit(self, "glide")
	
	if player.targeted_enemy == null or abs(Global.player.position - target_position).length_squared() > MAX_DISTANCE.length_squared() or player.mode == InnocentDevil.Mode.DEFENSIVE:
		target_position =  Global.player.position
	player.velocity = Vector2(target_position.x - player.position.x, target_position.y - player.position.y - MIN_HEIGHT_OFFSET)
	if sign(player.velocity.x)*player.facing_position < 0 and abs(player.velocity.x) > 20:
		turn_around()

	innocent_can_guard()
	innocent_check_is_hurt("hurt")
	innocent_can_die()
