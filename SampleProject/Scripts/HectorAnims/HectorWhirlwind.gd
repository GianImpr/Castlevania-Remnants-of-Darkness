extends State
class_name HectorWhirlwind
var can_perfect_guard: bool = false
@export var spinning_spear: Sprite2D
@export var spear: Sprite2D
@export var spear_scale_node: Node2D
@export var hector_hands: Sprite2D

func enter():
	hector_hands.flip_h = player.sprite.flip_h
	spear_scale_node.scale.x = player.facing_position
	spinning_spear.texture = Global.player.sprite.weapon.texture
	spear.texture = Global.player.sprite.weapon.texture
	animation.play("whirlwind")
	player.playSpecialAttackEffect()
	remove_momentum()
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	can_fall(true)
	check_is_hurt()
	can_die()
	
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
