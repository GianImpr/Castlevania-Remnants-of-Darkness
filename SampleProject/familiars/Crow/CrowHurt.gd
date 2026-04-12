extends State
class_name CrowHurt
const KNOCKBACK_STRENGTH: float = -100
const TWEEN_DURATION: float = 0.5
var deceleration_tween: Tween
const MERCY_INVINCIBILITY_DURATION: float = 1

func enter():
	player.invincible = true
	animation.play("hurt")
	deceleration_tween = get_tree().create_tween()
	player.velocity.x = KNOCKBACK_STRENGTH*player.facing_position
	player.velocity.y = 0
	deceleration_tween.tween_property(player, "velocity:x", 0, TWEEN_DURATION)
	
func Update(delta: float):
	innocent_can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func exit():
	player.is_hurt = false
	get_tree().create_timer(MERCY_INVINCIBILITY_DURATION, false).timeout.connect(func(): player.invincible = false)
	
func Physics_Update(delta: float):
	pass
