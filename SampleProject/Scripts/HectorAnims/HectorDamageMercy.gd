extends State
class_name HectorDamageMercy
@export var recoil_speed: Vector2
@export var ignore_landing: Timer
var can_perfect_guard: bool = false

func _ready() -> void:
	HectorGuardBreak.applyMercyInvincibility = applyMercyInvincibility

func enter():
	player.velocity.x = recoil_speed.x * player.facing_position * (-1)
	player.velocity.y = recoil_speed.y
	ignore_landing.start()
	animation.play("damage_mercy")
	
func exit():
	pass
	
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
	can_die()
	applyMercyInvincibility()

#Start the iframes and makes the player blink to indicate invulnerability
func applyMercyInvincibility() -> void:
	if player.is_on_floor() and ignore_landing.is_stopped():
		Transitioned.emit(self, "hard_landing")
		player.mercy_invincibility_duration.start()
		var tween = get_tree().create_tween()
		const TWEEN_LOOP_DURATION: float = 0.1
		const BLINK_SPEED: float = 0.3
		const NORMAL_COLOR: Color = Color(1,1,1,1)
		const TRANSPARENT_COLOR: Color = Color(1,1,1,0.5)
		tween.set_loops(player.mercy_invincibility_duration.wait_time/TWEEN_LOOP_DURATION/2)
		tween.tween_property(player.sprite, "self_modulate", NORMAL_COLOR, BLINK_SPEED).from(TRANSPARENT_COLOR)
