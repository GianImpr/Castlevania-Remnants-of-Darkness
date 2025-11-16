extends Node2D
class_name StoneCircle
var angle_portion: float = 45
const FULL_ANGLE: float = 360
const FINAL_SCALE: Vector2 = Vector2(1, 1)
const TWEEN_DURATION: float = 0.5
const HOVERING_DURATION: float = 2
@export var radius: float = 50
@export var rotating_speed: float = 2
@export var sound: PolyphonicAudio
@export var free_timer: Timer
@export var throw_timer: Timer
var target: Node2D
var cur_angle: float = 0
var start_tween: Tween
var stone_to_throw: int = 0
const STONE_THROW_DELAY: float = 0.7
const STONE_THROW_DELAY_OFFSET: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	free_timer.timeout.connect(queue_free)
	sound.play_sound_effect_from_library("stone_circle")
	target = Global.player
	start_tween = get_tree().create_tween().set_parallel()
	angle_portion = FULL_ANGLE / (get_child_count()-3)
	for i in range(0, get_child_count()-3):
		get_child(i).position = Vector2(radius * cos(deg_to_rad(angle_portion*i)), radius * sin(deg_to_rad(angle_portion*i)))
		get_child(i).stats.thrower_ATK = get_parent().stats.ATK
		get_tree().create_timer(TWEEN_DURATION, false).timeout.connect(func(): get_child(i).area.set_deferred("monitoring", true))
	
	start_tween.tween_property(self, "scale", FINAL_SCALE, TWEEN_DURATION)
	start_tween.tween_property(self, "modulate", Color.WHITE, TWEEN_DURATION).from(Color.TRANSPARENT)
	throw_timer.start(HOVERING_DURATION)
	throw_timer.timeout.connect(throwStone.bind(target))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	cur_angle = fposmod(cur_angle+delta*rotating_speed, FULL_ANGLE)
	for i in range(stone_to_throw, get_child_count()-3):
		get_child(i).position = Vector2(radius * cos(deg_to_rad(angle_portion*i)+cur_angle), radius * sin(deg_to_rad(angle_portion*i)+cur_angle))

func throwStone(victim: Node2D = null) -> void:
	sound.play_sound_effect_from_library("throw")
	get_child(stone_to_throw).hurtbox.set_deferred("disabled", false)
	const TIME_TO_GET_TO_TARGET: float = 1.5
	const FINAL_DESTINATION_OFFSET: float = 100
	var throw_tween: Tween = get_tree().create_tween()
	
	if victim != null:
		var victim_position: Vector2 = victim.global_position
		var parent: Node2D = get_parent()
		var final_position: Vector2
		if parent.global_position.x - victim_position.x < 0:
			final_position.x = MetSys.get_current_room_instance().get_size().x+FINAL_DESTINATION_OFFSET
		else:
			final_position.x = -FINAL_DESTINATION_OFFSET
		final_position.y = victim_position.y
		
		throw_tween.tween_property(get_child(stone_to_throw), "global_position", final_position, TIME_TO_GET_TO_TARGET)
	else:
		throw_tween.tween_property(get_child(stone_to_throw), "global_position", Vector2(0, randf_range(0, 480)), TIME_TO_GET_TO_TARGET)

	stone_to_throw += 1
	
	if stone_to_throw < get_child_count()-3:
		throw_timer.start(STONE_THROW_DELAY+randf_range(-STONE_THROW_DELAY_OFFSET, STONE_THROW_DELAY_OFFSET))
