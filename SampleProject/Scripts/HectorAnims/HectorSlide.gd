extends State
class_name HectorSlide
@export var slide_speed: float
@export var trail_scene: PackedScene
@export var debris_scene: PackedScene
@export var trail_timer: Timer
@export var debris_timer: Timer
@export var turn_timer: Timer
var can_perfect_guard: bool = true
var deceleration_tween: Tween
const SLIDE_CANCEL_EXTRA_VERTICAL_MOMENTUM: float = 400
const SLIDE_CANCEL_SPEED_BOOST_MULTIPLIER: float = 1.12
const DEBRIS_POSITION: Vector2 = Vector2(40,68)
const DECELERATION_DURATION: float = 0.55

func enter():
	reset_ledge_detection()
	if not turn_timer.timeout.is_connected(applySpeed):
		turn_timer.timeout.connect(applySpeed)
	animation.play("slide")
	turn_timer.start()
	sound.play_sound_effect_from_library("slide")
	player.instantiateScene(trail_scene, true, Vector2(0,0))
	player.instantiateScene(debris_scene, false, Vector2(player.facing_position*DEBRIS_POSITION.x,DEBRIS_POSITION.y))
	trail_timer.start()
	debris_timer.start()
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_fall(true, SLIDE_CANCEL_EXTRA_VERTICAL_MOMENTUM)
	check_is_hurt()
	can_die()
	if player.is_on_wall():
		debris_timer.stop()
		
	if not animation.is_playing():
		player.skip_crouch_anim = true
		Transitioned.emit(self, "crouch")
		
func exit():
	trail_timer.stop()
	debris_timer.stop()
	if deceleration_tween:
		deceleration_tween.kill()
	player.velocity.x *= SLIDE_CANCEL_SPEED_BOOST_MULTIPLIER
	
	if player.state_machine.new_state is HectorFalling:
		sound.play_sound_effect_from_library("slide_jump")

func _on_trail_timer_timeout() -> void:
	player.instantiateScene(trail_scene, true, Vector2(0,0))
	
func _on_debris_timer_timeout() -> void:
	player.instantiateScene(debris_scene, false, Vector2(player.facing_position*DEBRIS_POSITION.x,DEBRIS_POSITION.y), true)

func applySpeed() -> void:
	player.velocity.x = slide_speed * player.facing_position
	deceleration_tween = get_tree().create_tween()
	deceleration_tween.tween_property(player, "velocity:x", 0, DECELERATION_DURATION)
