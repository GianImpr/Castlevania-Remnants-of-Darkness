extends State
class_name CrowGlide
const OFFSET: Vector2 = Vector2(10, -72)
@export var sprite: Sprite2D

func enter():
	if not player.can_glide:
		return
	
	player.can_glide = false
	Global.player.transitionToState("glide")
	if Global.player.is_on_floor_only():
		animation.play("glide_ground")
	else:
		animation.play("glide")
	
func exit():
	player.prepare_for_flight = false
	sprite.self_modulate = Color.WHITE
	HectorGlide.interrupted = true
	
func Update(delta: float):
	innocent_check_is_hurt("hurt")
	innocent_can_die()
	
	if HectorGlide.interrupted:
		Transitioned.emit(self, "fly")

func Physics_Update(_delta: float):
	if Global.player.facing_position*player.facing_position < 0:
		turn_around()
		
	player.global_position.y = Global.player.global_position.y + OFFSET.y
	player.global_position.x = Global.player.global_position.x + OFFSET.x*player.facing_position
