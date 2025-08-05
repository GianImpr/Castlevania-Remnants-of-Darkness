extends Node2D
class_name BrokenCandle
var children: Array[RigidBody2D]
@export var base_velocity: Vector2
@export var delete_timer: Timer
@export var explosion: PackedScene
var facing_position: int = Global.player.facing_position
const FLAME_POSITION_OFFSET: Vector2 = Vector2(0,-8)

func _ready() -> void:
	for child in get_children():
		if child is RigidBody2D:
			child.linear_velocity = base_velocity * Vector2(randf_range(0.5, 1.5)*facing_position, randf_range(0.5, 1.5))
			children.append(child)
		
func _physics_process(delta: float) -> void:
	for child in children:
		child.move_local_x(delta)
		if child and abs(child.linear_velocity) < Vector2(40, 40):
			if explosion == null:
				child.get_child(2).play("destroy", -1, 2.5)
			else:
				child.visible = false
				var flame = explosion.instantiate()
				flame.global_position = child.get_child(0).global_position + FLAME_POSITION_OFFSET
				MetSys.get_current_room_instance().add_child(flame)
			children.erase(child)
	if children.size() == 0:
		delete_timer.start()
		

func _on_delete_timer_timeout() -> void:
	queue_free()
