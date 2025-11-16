extends State
class_name HectorBackdash
@export var backdash_speed: float
@export var trail_scene: PackedScene
@export var debris_scene: PackedScene
@export var trail_timer: Timer
@export var debris_timer: Timer
var can_perfect_guard: bool = true
const STARTING_ANIM_POSITION: float = 0.5
const DEBRIS_POSITION: Vector2 = Vector2(40,68)
const DECELERATION_RATE: float = 54


func enter():
	animation.play("run_end", -1, -1, true)
	animation.seek(STARTING_ANIM_POSITION)
	player.velocity.x = backdash_speed * player.facing_position * (-1)
	sound.play_sound_effect_from_library("backdash")
	player.instantiateScene(trail_scene, true, Vector2(0,0))
	player.instantiateScene(debris_scene, false, Vector2(player.facing_position*DEBRIS_POSITION.x,DEBRIS_POSITION.y))
	trail_timer.start()
	debris_timer.start()
	if randi_range(0, 1) > 0:
		voice.play_sound_effect_from_library("Backdash")
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_perform("jump", true)
	can_perform("crouch", false)
	can_fall(true)
	check_is_hurt()
	can_guard()
	can_die()
	if player.is_on_wall():
		debris_timer.stop()
		
	if animation.is_playing():
		player.velocity.x *= (DECELERATION_RATE*delta)
	else:
		player.velocity.x = 0
		Transitioned.emit(self, "idle")
		
func exit():
	trail_timer.stop()
	debris_timer.stop()

func _on_trail_timer_timeout() -> void:
	player.instantiateScene(trail_scene, true, Vector2(0,0))
	
func _on_debris_timer_timeout() -> void:
	player.instantiateScene(debris_scene, false, Vector2(player.facing_position*DEBRIS_POSITION.x,DEBRIS_POSITION.y))
