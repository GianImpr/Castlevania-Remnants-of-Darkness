extends Node2D
var children: Array[RigidBody2D]
@export var base_velocity: Vector2
@export var delete_timer: Timer
@export var sound: Node
var facing_position: int
const ANIMATION_CHILD_INDEX: int = 2
const ANIMATION_SPEED: float = 2.5
const MIN_SPEED_MULTIPLIER: float = 0.5
const MAX_SPEED_MULTIPLIER: float = 1.5

func _ready() -> void:
	sound.play_sound_effect_from_library("dying")
	for child in get_children():
		if child is RigidBody2D:
			child.linear_velocity = base_velocity * Vector2(randf_range(MIN_SPEED_MULTIPLIER, MAX_SPEED_MULTIPLIER)*facing_position*(-1), randf_range(MIN_SPEED_MULTIPLIER, MAX_SPEED_MULTIPLIER))
			children.append(child)
		
func _physics_process(delta: float) -> void:
	for child in children:
		child.move_local_x(delta)
		if child and child.get_contact_count() > 0:
			sound.play_sound_effect_from_library("drop")
			child.get_child(ANIMATION_CHILD_INDEX).play("destroy", -1, ANIMATION_SPEED)
			children.erase(child)
	if children.size() == 0:
		delete_timer.start()
		

func _on_delete_timer_timeout() -> void:
	queue_free()
