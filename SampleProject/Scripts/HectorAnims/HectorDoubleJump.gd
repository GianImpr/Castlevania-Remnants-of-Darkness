extends State
class_name HectorDoubleJump
@export var JUMP_VELOCITY: float
var can_perfect_guard: bool = true
var snapped_on_platform: bool
var cur_facing_position: int

func enter():
	player.can_double_jump = false
	snapped_on_platform = false
	if player.facing_position == 1:
		animation.play("double_jump", -1, 1.3)
	else:
		animation.play("double_jump_reverse", -1, 1.3)
	cur_facing_position = player.facing_position
	animation.seek(0)
	player.velocity.y = JUMP_VELOCITY
	sound.play_sound_effect_from_library("double_jump")


func exit():
	animation.stop()
	player.sprite.rotation = 0
	
func Physics_Update(delta: float):
		
	if not Input.is_action_pressed("jump") and player.velocity.y < 0 and not snapped_on_platform:
		player.velocity.y *= 0.95*delta
		
	#Check if player should get pushed above a one-way platform
	if animation.current_animation_position <= 0.6 and player.raycast.is_colliding() and player.raycast.get_collider() is TileMapLayer and player.velocity.y > 100 and not snapped_on_platform:
		var collider: TileMapLayer = player.raycast.get_collider()
		var collision_position: Vector2 = player.raycast.get_collision_point()
		var tile_coords = collider.local_to_map(collision_position)
		var tile: TileData = collider.get_cell_tile_data(tile_coords)
		if tile.is_collision_polygon_one_way(1, 0):
			snapped_on_platform = true
			player.position.y = collision_position.y - Global.player.hurtbox.shape.get_rect().size.y -42
			#get_tree().create_tween().tween_property(player, "global_position", player.position-abs(collision_position-player.position), 0.05)
	
	can_move_with_momentum(player.velocity.y < 200)
	can_turn()
	updateFacingPosition()
	can_attack()
	can_land()
	can_die()
	check_is_blocking()
	check_is_hurt()

func updateFacingPosition() -> void:
	var cur_animation_pos: float = animation.current_animation_position
	if player.facing_position != cur_facing_position:
		if player.facing_position == 1:
			animation.play("double_jump", -1, 1.3)
		else:
			animation.play("double_jump_reverse", -1, 1.3)
		animation.seek(cur_animation_pos)
		cur_facing_position = player.facing_position
