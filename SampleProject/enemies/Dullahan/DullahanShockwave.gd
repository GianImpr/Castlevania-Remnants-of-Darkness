extends State
class_name DullahanShockwave
@export var red_spark_scene: PackedScene
@export var jump_strength: float
@export var shockwave_effect: GPUParticles2D
@export var shockwave_hitbox: CollisionShape2D
var jumping: bool
var shockwave_done: bool
const SHOCKWAVE_DISABLE_TIME_NORMAL: float = 2.45
const SHOCKWAVE_DISABLE_TIME_CRAZY: float = 2.5

func enter():
	animation.play("shockwave")
	jumping = false
	shockwave_done = false
	var red_spark = red_spark_scene.instantiate()
	player.add_child(red_spark)
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
	
	if jumping and player.is_on_floor() and not shockwave_done:
		performShockwave()
		
	if player.phase_two and animation.current_animation_position > 2.6:
		Transitioned.emit(self, "throw_head")
		
	if animation.current_animation_position >= SHOCKWAVE_DISABLE_TIME_NORMAL and Global.game.difficulty == Global.game.Difficulty.NORMAL:
		shockwave_hitbox.disabled = true
	elif animation.current_animation_position >= SHOCKWAVE_DISABLE_TIME_CRAZY and Global.game.difficulty == Global.game.Difficulty.CRAZY:
		shockwave_hitbox.disabled = true
		
func jump():
	jumping = true
	player.velocity.y = jump_strength * (-1)
	
func performShockwave():
	shockwave_effect.emitting = true
	shockwave_done = true
	
func modulateRoomColor() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(get_tree().current_scene, "modulate", Color(0.4, 0.5, 1), 0.2)
	
func resetModulateRoomColor() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(get_tree().current_scene, "modulate", Color(1, 1, 1), 0.3)
