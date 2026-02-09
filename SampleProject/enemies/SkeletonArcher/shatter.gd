extends Node2D
var children: Array[RigidBody2D]
@export var base_velocity: Vector2
@export var delete_timer: Timer
@export var sound: Node
@export var flame_texture: Sprite2D
var facing_position: int
const SPRITE_INDEX: int = 0
const COLLISION_INDEX: int = 1
const ANIMATION_SPEED: float = 2.5
const MIN_SPEED_MULTIPLIER: float = 0.5
const MAX_SPEED_MULTIPLIER: float = 1.5
const VISIBILITY_DELAY: float = 0.02
const ANIMATION_DURATION: float = 0.44
const LAST_ANIM_FRAME: float = 10

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
			var child_sprite: Sprite2D = child.get_child(SPRITE_INDEX)
			var child_collision: CollisionShape2D = child.get_child(COLLISION_INDEX)
			child_sprite.visible = false
			child_sprite.global_position = child_collision.global_position+child_collision.shape.size/2.0
			child_sprite.texture = flame_texture.texture
			child_sprite.hframes = flame_texture.hframes
			child_sprite.vframes = flame_texture.vframes
			child_sprite.frame = 0
			get_tree().create_timer(VISIBILITY_DELAY, false).timeout.connect(func(): child_sprite.visible = true)
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(child_sprite, "frame", LAST_ANIM_FRAME, ANIMATION_DURATION)
			tween.finished.connect(child_sprite.queue_free)
			children.erase(child)
	if children.size() == 0:
		delete_timer.start()
		

func _on_delete_timer_timeout() -> void:
	queue_free()
