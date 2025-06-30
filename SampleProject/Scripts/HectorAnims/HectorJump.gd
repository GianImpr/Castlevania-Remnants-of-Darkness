extends State
class_name HectorJump
@export var JUMP_VELOCITY: float
var can_perfect_guard: bool = true


func enter():
	animation.play("jump", -1, 1.3)
	animation.seek(0)
	player.velocity.y = JUMP_VELOCITY
	sound.play_sound_effect_from_library("jump")
		
func Update(delta: float):
	pass
	
func Physics_Update(delta: float):
		
	if not Input.is_action_pressed("jump") and player.velocity.y < 0:
		player.velocity.y *= 0.95*delta
		
	#Check if player should get pushed above a one-way platform
	if animation.current_animation_position <= 0.5 and player.raycast.is_colliding() and player.raycast.get_collider() is TileMapLayer and player.velocity.y > 0:
		var collider: TileMapLayer = player.raycast.get_collider()
		var collision_position: Vector2 = player.raycast.get_collision_point()
		var tile_coords = collider.local_to_map(collision_position)
		var tile: TileData = collider.get_cell_tile_data(tile_coords)
		if tile.is_collision_polygon_one_way(0, 0):
			player.position -= abs(collision_position-player.position)/4
	
	can_move_with_momentum(player.velocity.y < 200)
	can_turn()
	can_attack()
	can_land()
	can_die()
	check_is_blocking()
	check_is_hurt()
