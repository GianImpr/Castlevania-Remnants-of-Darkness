extends Node2D
class_name HealOrb
const HEALING_POWER: int = 8
const INITIAL_MOMENTUM_SPEED: Vector2 = Vector2(300, 300)
const MAX_SPEED: Vector2 = Vector2(400, 300)
var velocity: Vector2
var initial_momentum_tween: Tween
var direction: Vector2 = Vector2(1, 1)
var actual_direction: Vector2 = Vector2(1, 1)
const INITIAL_MOMENTUM_DURATION: float = 0.4
const DISTANCE_THRESHOLD: float = 5
var initial_momentum_finished: bool = false
@export var area: Area2D
var turning_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_momentum_tween = get_tree().create_tween()
	initial_momentum_tween.tween_property(self, "velocity", INITIAL_MOMENTUM_SPEED, INITIAL_MOMENTUM_DURATION)
	initial_momentum_tween.finished.connect(activateOrb)
	actual_direction = Vector2(Global.player.facing_position, -1)
	
func _process(delta: float) -> void:
	if initial_momentum_finished:
		if Global.player.global_position.x-DISTANCE_THRESHOLD > global_position.x:
			direction.x = 1
		elif Global.player.global_position.x+DISTANCE_THRESHOLD <= global_position.x:
			direction.x = -1
	
		if Global.player.global_position.y-DISTANCE_THRESHOLD > global_position.y:
			direction.y = 1
		elif Global.player.global_position.y+DISTANCE_THRESHOLD <= global_position.y:
			direction.y = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if initial_momentum_finished:
		actual_direction.x = clampf(actual_direction.x+delta*direction.x*5, -1, 1)
		actual_direction.y = clampf(actual_direction.y+delta*direction.y*5, -1, 1)
	global_position = global_position + velocity * actual_direction * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	(body as HectorPlayer).heal(HEALING_POWER, false)
	queue_free()

func activateOrb() -> void:
	initial_momentum_finished = true
	area.set_deferred("monitoring", true)
	velocity = MAX_SPEED
