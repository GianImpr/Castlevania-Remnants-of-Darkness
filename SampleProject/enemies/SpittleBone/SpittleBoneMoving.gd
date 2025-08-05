extends State
@export var SPEED: float
@export var initial_detection_delay_timer: Timer
@export var collision_box: CollisionShape2D

const ROTATING_SPEED: float = 15
var crawling_direction: Vector2 = Vector2.LEFT
var snap_vector: Vector2 = Vector2.ZERO
var target_rotation_angle: float

func enter():
	animation.play("moving")
	target_rotation_angle = crawling_direction.angle()
	
func exit():
	pass

func Update(delta: float):
	pass

func Physics_Update(delta: float):
	player = (player as Enemy)
	var collision: KinematicCollision2D = player.move_and_collide(SPEED*delta*crawling_direction)
	rotateTowardsTargetVector(delta)
	if collision != null:
		setVelocitySnapRotation(collision)
	else:
		if (not player.is_on_floor()):
			crawling_direction += snap_vector.normalized()

func setVelocitySnapRotation(collision: KinematicCollision2D) -> void:
	crawling_direction = -collision.get_normal().rotated(PI/2)
	target_rotation_angle = crawling_direction.angle() + PI;
	snap_vector = collision.get_normal().rotated(PI)

func rotateTowardsTargetVector(delta):
	player.rotation = lerp_angle(player.rotation, target_rotation_angle, ROTATING_SPEED*delta)
