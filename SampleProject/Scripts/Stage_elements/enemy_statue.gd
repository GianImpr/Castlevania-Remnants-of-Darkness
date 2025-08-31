extends BreakableWall
class_name EnemyStatue
@export var collision: CollisionShape2D
@export var sprite: Sprite2D

func _ready() -> void:
	sprite.texture = wall.get_child(0).texture
	get_child(0).visible = false
	#get_tree().create_timer(1).timeout.connect(_on_area_2d_area_entered.bind(null))

func _on_area_2d_area_entered(area: Area2D) -> void:
	sprite.visible = false
	get_child(0).visible = true
	collision.set_deferred("disabled", true)
	wall.detonate()
	sound.play_sound_effect_from_library("break")
