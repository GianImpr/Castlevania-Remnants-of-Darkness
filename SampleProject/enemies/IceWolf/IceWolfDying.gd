extends State
class_name IceWolfDying
@export var corpse_scene: PackedScene
const OFFSET: Vector2 = Vector2(-30, -57)
const OFFSET_RIGHT_SIDE: float = 32

func enter():
	player.velocity.x = 0
	animation.play("dying")
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	pass

func generateCorpse() -> void:
	var corpse = corpse_scene.instantiate()
	corpse.global_position.x = player.global_position.x + OFFSET.x*player.facing_position*(-1)
	corpse.global_position.y = player.global_position.y + OFFSET.y
	if player.facing_position == 1:
		corpse.global_position.x -= OFFSET_RIGHT_SIDE
		corpse.sprite.scale.x *= -1
		corpse.wall.get_child(0).scale.x *= -1
		corpse.wall.get_child(0).global_position.x -= OFFSET_RIGHT_SIDE
	MetSys.get_current_room_instance().add_child(corpse)
