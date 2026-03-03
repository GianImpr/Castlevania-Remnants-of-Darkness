extends State
class_name HectorSwordSpin
@export var sword_spin: Node2D
@export var sword_spin_hitbox: CollisionShape2D
var can_perfect_guard: bool = false

func enter():
	player.playSpecialAttackEffect()
	animation.play("sword_throw", -1, 1.1)
	player.sprite.weapon.animation.play("boomerang", -1, 1.1)

func exit():
	sword_spin.visible = false
	sword_spin_hitbox.disabled = true
	if player.sprite.weapon.boomerang:
		player.sprite.weapon.boomerang.visible = false

func Update(delta: float):
	can_perform("backdash", true)
	can_fall(true)
	check_is_hurt()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

	
func Physics_Update(delta: float):
	remove_momentum()
