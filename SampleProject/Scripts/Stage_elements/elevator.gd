@tool
extends Node2D
class_name Elevator

@export var height: float:
	set(value):
		height = value
		setHeight()
@export var chain: Sprite2D
@export var elevator: Sprite2D
@export var collision_box: CollisionShape2D
var can_lift: bool = false
var should_go_up: bool = true
var moving: bool = false
@export var move: bool = false
@export var sound: PolyphonicMenuAudio

func _ready() -> void:
	setHeight()
	
func _process(delta: float) -> void:
	if move:
		move = false
		_moveElevator()
		
	if can_lift and (Input.is_action_just_pressed("up_arrow") and should_go_up or Input.is_action_just_pressed("crouch") and not should_go_up) and not moving:
		_moveElevator()
		

	
func _moveElevator():
	sound.play_sound_effect_from_library("elevator")
	moving = true
	if should_go_up:
		Global.player.tap_up.dismiss()
		await _moveTo(32)
		should_go_up = false
	else:
		await _moveTo(852)
		should_go_up = true
	moving = false
		
func _moveTo(height_value: float):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "height", height_value, 11)
	await tween.finished
	if can_lift and not should_go_up:
		Global.player.tap_up.appear()

func setHeight():
	if chain:
		chain.region_rect.size.y = height
		elevator.position.y = 72 + height*2
		collision_box.position.y = 136 + height*2


func _on_area_2d_body_entered(body: Node2D) -> void:
	can_lift = true
	if not moving and should_go_up:
		Global.player.tap_up.appear()


func _on_area_2d_body_exited(body: Node2D) -> void:
	can_lift = false
	if not moving and should_go_up:
		Global.player.tap_up.dismiss()
