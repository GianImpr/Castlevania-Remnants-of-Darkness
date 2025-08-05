extends RigidBody2D
@export var SPEED: Vector2
@export var rotate_node: Node2D
@export var sprite: Sprite2D
@export var trail_scene: PackedScene
@export var trail_frequency: Timer
var direction: int

func _ready() -> void:
	sprite.texture = Global.player.sprite.weapon.texture
	linear_velocity = SPEED
	direction = Global.player.facing_position
	linear_velocity.x *= direction
	rotate_node.scale.x = direction

func _physics_process(delta: float) -> void:
	move_local_x(delta)
	move_local_y(delta)

func createTrail() -> void:
	var trail = trail_scene.instantiate()
	trail.texture = sprite.texture
	trail.vframes = sprite.vframes
	trail.hframes = sprite.hframes
	trail.offset = sprite.offset
	trail.global_position = sprite.global_position
	trail.scale = Vector2(2, 2)
	trail.rotation_degrees = sprite.rotation_degrees
	trail.show_behind_parent = true
	trail.z_index = 9
	get_parent().add_child(trail)


func _on_trail_timeout() -> void:
	createTrail()
