extends State
class_name MermanFire
@export var fireball_scene: PackedScene
@export var iceball_scene: PackedScene
@export var RECOIL_SPEED: Vector2
const FIREBALL_OFFSET: Vector2 = Vector2(-44,-42)

func enter():
	can_turnaround_with_scale()
	player.velocity.x = 0
	animation.play("fire")
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	
	if not animation.is_playing() and player.is_on_floor():
		Transitioned.emit(self, "recoil")

func Physics_Update(delta: float):
	pass

func shootFireball() -> void:
	var fireball
	if player.ice_elemental:
		fireball = iceball_scene.instantiate()
	else:
		fireball = fireball_scene.instantiate()
	sound.play_sound_effect_from_library("fire")
	fireball.stats.thrower_ATK = player.stats.ATK
	fireball.global_position = player.global_position
	fireball.global_position.x += FIREBALL_OFFSET.x*player.facing_position*(-1)
	fireball.global_position.y += FIREBALL_OFFSET.y
	fireball.direction = player.facing_position
	fireball.scale.x *= player.facing_position*(-1)
	MetSys.get_current_room_instance().add_child(fireball)
	player.velocity = RECOIL_SPEED
	player.velocity.x *= player.facing_position
