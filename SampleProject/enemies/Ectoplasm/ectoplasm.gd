extends Enemy
class_name Ectoplasm

var facing_position: int
@export var is_moving: bool = true
@export var contact_damage_multiplier: float = 1
var navigation_tween: Tween
var navigation_duration: float
var navigation_cur_time: float
@export var aura: CPUParticles2D
@export var shining_animation: AnimationPlayer
@export var GREEN_PARTICLES: CompressedTexture2D

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.area_entered.connect(_on_area_2d_area_entered)
	if randi_range(0, 1) == 0:
		shining_animation.play("idle")
	else:
		shining_animation.play("idle_green")
		aura.texture = GREEN_PARTICLES

func _physics_process(delta: float) -> void:
	if not is_on_floor() and motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		velocity += get_gravity()*2 * delta
	
	remove_glow_if_glowing()
	move_and_slide()
	if navigation_tween and navigation_tween.is_running():
		navigation_cur_time += delta
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(contact_damage_multiplier, body, hitbox_iframe, 0, false, Global.Attribute.CURSE)


func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.get_child(0).set_deferred("disabled", false)
		
func initializeNavigation(speed: Vector2, duration: float):
	if stats.HP <= 0:
		return
	navigation_tween = get_tree().create_tween()
	navigation_tween.set_ease(Tween.EASE_IN_OUT)
	navigation_tween.bind_node(self)
	navigation_tween.set_loops()
	const SPEEDS: Array[Vector2] = [Vector2(1,1), Vector2(-1,1), Vector2(-1,-1), Vector2(1,-1)]
	var starting_speed: int = 0
	if navigation_duration > 0:
		starting_speed = navigation_cur_time/navigation_duration
	for i in range(0, SPEEDS.size()):
		navigation_tween.tween_property(self, "velocity", speed*SPEEDS[(starting_speed+i)%SPEEDS.size()], duration)
	navigation_cur_time = 0
	navigation_duration = duration

func navigationDone() -> void:
	navigation_tween.kill()
