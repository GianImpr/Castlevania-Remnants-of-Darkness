extends RigidBody2D
@export var number: int
@export var eventID: int
@export var animation: AnimationPlayer
@export var hurtbox: Area2D
@export var label: Label
@export var enemy_portrait: TextureRect
@export var enemy_image: CompressedTexture2D

func _ready():
	hurtbox.monitoring = not Global.player.stats.event_flags[eventID]
	label.text = str(number)
	enemy_portrait.texture = enemy_image
	
func updateNumber():
	number = (number+1)%10
	label.text = str(number)

func _on_area_2d_area_entered(area: Area2D) -> void:
	animation.play("on_hit")
