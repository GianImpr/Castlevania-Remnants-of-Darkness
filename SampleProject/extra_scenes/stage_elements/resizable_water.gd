extends Node2D
class_name Water

@export var big_water_splash: PackedScene
@export var small_water_splash: PackedScene
@export var sound: PolyphonicAudio
@export var collision: CollisionShape2D
@export var water_sprite: Sprite2D

var excluded_bodies: Array[CharacterBody2D]
var track_bodies: Array[CharacterBody2D]
static var can_produce_small_sound: bool = true
const SMALL_SPLASH_TIME_INTERVAL: float = 0.12
const VELOCITY_FOR_BIG_SPLASH: float = 500
const SPLASH_SPAWN_OFFSET: float = 30
const SPLASH_SIZE: float = 60

func _ready() -> void:
	excluded_bodies.clear()
	track_bodies.clear()

func _process(delta: float) -> void:
	for body: CharacterBody2D in track_bodies:
		if body.velocity.x != 0 and body not in excluded_bodies:
			excluded_bodies.append(body)
			triggerSmallSplash(body)
			get_tree().create_timer(SMALL_SPLASH_TIME_INTERVAL, false).timeout.connect(func(): excluded_bodies.erase(body))
			

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.velocity.y > 0:
			triggerBigSplash(body)
		track_bodies.append(body)
	else:
		triggerSmallSplash(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.velocity.y < 0:
			triggerBigSplash(body)
		track_bodies.erase(body)
		
func _on_area_2d_area_entered(area: Area2D) -> void:
	_on_area_2d_body_entered(area.get_parent())
	
func _on_area_2d_area_exited(area: Area2D) -> void:
	_on_area_2d_body_exited(area.get_parent())

func triggerBigSplash(body: Node2D) -> void:
	var big_splash = big_water_splash.instantiate()
	var x_pos: float = min(body.global_position.x-SPLASH_SPAWN_OFFSET, water_sprite.global_position.x-water_sprite.texture.get_size().x*water_sprite.scale.x/2+collision.shape.size.x*collision.global_scale.x-SPLASH_SIZE)
	x_pos = max(x_pos, water_sprite.global_position.x-water_sprite.texture.get_size().x*water_sprite.scale.x/2)
	
	big_splash.global_position = Vector2(x_pos, global_position.y+get_child(0).position.y)
	if MetSys.get_current_room_instance():
		MetSys.get_current_room_instance().add_child.call_deferred(big_splash)
	sound.play_sound_effect_from_library("big_splash")
	if body.velocity.y > VELOCITY_FOR_BIG_SPLASH:
		big_splash.bigSplash()
	else:
		big_splash.smallSplash()

func triggerSmallSplash(body: Node2D) -> void:
	var small_splash = small_water_splash.instantiate()
	var x_pos: float = min(body.global_position.x-SPLASH_SPAWN_OFFSET, (water_sprite.global_position.x-water_sprite.texture.get_size().x*water_sprite.scale.x/2)+collision.shape.size.x*collision.global_scale.x-SPLASH_SIZE)
	x_pos = max(x_pos, water_sprite.global_position.x-water_sprite.texture.get_size().x*water_sprite.scale.x/2)

	small_splash.global_position = Vector2(x_pos, global_position.y+get_child(0).position.y)
	if MetSys.get_current_room_instance():
		MetSys.get_current_room_instance().add_child.call_deferred(small_splash)
		
	if can_produce_small_sound:
		can_produce_small_sound = false
		get_tree().create_timer(SMALL_SPLASH_TIME_INTERVAL, false).timeout.connect(func(): can_produce_small_sound = true)
		sound.play_sound_effect_from_library("small_splash")
		
	
