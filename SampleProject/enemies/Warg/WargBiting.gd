extends State
class_name WargBiting
@export var BITING_SPEED: float
@export_range(0, 3, 0.1, "suffix:s") var DECELERATION_DURATION: float
const TRANSITION_TO_IDLE_DELAY: float = 0.2
var tween: Tween

func enter():
	player.velocity.x = 0
	animation.play("biting")
	
func exit():
	if tween != null and tween.is_running():
		tween.kill()

func Update(delta: float):
	enemy_can_die()

func Physics_Update(delta: float):
	pass

func applyBitingSpeed() -> void:
	sound.play_sound_effect_from_library("biting")
	player.velocity.x = BITING_SPEED * player.facing_position
	tween = get_tree().create_tween()
	tween.bind_node(player)
	tween.tween_property(player, "velocity", Vector2(0, player.velocity.y), DECELERATION_DURATION)
	tween.finished.connect(func(): get_tree().create_timer(TRANSITION_TO_IDLE_DELAY).timeout.connect(func(): Transitioned.emit(self, "idle")))
