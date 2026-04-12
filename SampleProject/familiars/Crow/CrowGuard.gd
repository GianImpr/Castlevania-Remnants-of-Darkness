extends State
class_name CrowGuard
const RECOIL: float = -200
var recoil_tween: Tween
const RECOIL_DURATION: float = 1
const INVINCIBILITY_DURATION: float = 1

func enter():
	animation.play("guard_2")
	player.velocity = Vector2(RECOIL*player.facing_position, 0)
	recoil_tween = get_tree().create_tween()
	recoil_tween.tween_property(player, "velocity:x", 0, RECOIL_DURATION)

func exit():
	player.attack_blocked = false
	player.is_hurt = false
	player.invincible = true
	get_tree().create_timer(INVINCIBILITY_DURATION, false).timeout.connect(func(): player.invincible = false)
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
