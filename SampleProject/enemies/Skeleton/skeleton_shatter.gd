extends Node2D
var children: Array[RigidBody2D]
@export var base_velocity: Vector2
@export var delete_timer: Timer
@export var sound: Node
var facing_position: int

func _ready() -> void:
	sound.play_sound_effect_from_library("dying")
	for child in get_children():
		if child is RigidBody2D:
			child.linear_velocity = base_velocity * Vector2(randf_range(0.5, 1.5)*facing_position*(-1), randf_range(0.5, 1.5))
			children.append(child)
		
func _physics_process(delta: float) -> void:
	for child in children:
		child.move_local_x(delta)
		if child and abs(child.linear_velocity) < Vector2(40, 40):
			sound.play_sound_effect_from_library("drop")
			child.get_child(2).play("destroy", -1, 2.5)
			children.erase(child)
	if children.size() == 0:
		delete_timer.start()
		

func _on_delete_timer_timeout() -> void:
	queue_free()
