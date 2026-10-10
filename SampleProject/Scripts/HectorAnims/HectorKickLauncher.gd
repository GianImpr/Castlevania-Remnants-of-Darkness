extends State
class_name HectorKickLauncher
var can_perfect_guard: bool = true
@export var kick_launcher_hitbox: CollisionShape2D
const INITIAL_VERTICAL_SPEED: float = -700
const CAN_LAND_AFTER_SECONDS: float = 0.5
@export var trail_timer: Timer
@export var trail_scene: PackedScene

func _ready() -> void:
	trail_timer.timeout.connect(_on_trail_timer_timeout)

func enter():
	player.playSpecialAttackEffect()
	animation.play("kick_launcher")
	voice.play_sound_effect_from_library("heavy_attack_3")
	remove_momentum()
	
func exit():
	trail_timer.stop()
	kick_launcher_hitbox.set_deferred("disabled", true)
	
func Update(delta: float):
	check_is_hurt()
	can_die()
	if not kick_launcher_hitbox.disabled:
		can_move_with_momentum(player.velocity.y < 200)
		can_turn()

func Physics_Update(delta: float):
	if not animation.is_playing():
		trail_timer.stop()
		can_fall(false)
		
	if player.velocity.y >= 0 and animation.current_animation_position >= CAN_LAND_AFTER_SECONDS:
		can_land()
		can_double_jump()
		can_attack()
		
func applySpeed() -> void:
	trail_timer.start()
	player.velocity.y = INITIAL_VERTICAL_SPEED

func _on_trail_timer_timeout() -> void:
	player.instantiateScene(trail_scene, true, Vector2(0,0))
