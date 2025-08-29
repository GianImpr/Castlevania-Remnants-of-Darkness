extends State
class_name HectorPetrified
const PETRIFY_DURATION: float = 30
const MINIMUM_TICKS: float = 10
var ticks_left: float
const RESISTANCE_COEFFICIENT: int = 5
const INPUTS: Array[String] = ["up_arrow", "move_right", "move_left", "crouch", "attack", "circle", "jump"]
@export var hector_statue_scene: PackedScene
@export var debris: CPUParticles2D
@export var hurtbox: CollisionShape2D
const IFRAME_TIME: float = 1.5
var can_perfect_guard: bool = false
var broken: bool
static var applyMercyInvincibility: Callable
static var resetGame: Callable

var shake_tween: Tween
const FADE_DELAY_TIME: float = 3

func enter():
	animation.stop()
	broken = false
	player.is_hurt = false
	player.velocity = Vector2.ZERO
	player.sprite.setPetrify(true)
	ticks_left = max(PETRIFY_DURATION - player.stats.Stats["CON"] / RESISTANCE_COEFFICIENT, MINIMUM_TICKS)

func exit():
	pass

func Update(delta: float):
	for input in INPUTS:
		if Input.is_action_just_pressed(input) and player.stats.Stats["HP"] > 0:
			if shake_tween == null or not shake_tween.is_valid():
				shake_tween = get_tree().create_tween()
				shake_tween.tween_property(Global.player.sprite, "rotation_degrees", randf_range(-5, 5), 0.03)
				shake_tween.tween_property(Global.player.sprite, "rotation_degrees", 0, 0.03)
			debris.global_position = player.global_position + Vector2(0, 26)
			debris.emitting = true
			ticks_left -= 1
			
	if player.stats.Stats["HP"] <= 0 and not broken:
		breakStatue()
		broken = true
		player.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		hurtbox.disabled = true
		get_tree().create_timer(FADE_DELAY_TIME).timeout.connect(resetGame)
		player.visible = false
		

	if ticks_left <= 0 and not broken:
		broken = true
		animation.play("hurt", -1, 1.2)
		applyMercyInvincibility.call()
		player.sprite.setPetrify(false)
		player.stats.current_status = player.stats.Ailment.GOOD
		breakStatue()
	else:
		if player.is_hurt:
			get_tree().create_timer(IFRAME_TIME).timeout.connect(func(): player.is_hurt = false)
	
	if ticks_left <= 0 and not animation.is_playing() and player.stats.Stats["HP"] > 0:
		Transitioned.emit(self, "idle")


func Physics_Update(delta: float):
	pass

func breakStatue() -> void:
	var hector_statue = hector_statue_scene.instantiate()
	MetSys.get_current_room_instance().add_child(hector_statue)
	hector_statue.global_position = player.global_position
	
