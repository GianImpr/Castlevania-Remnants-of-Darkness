extends State
class_name IceWolfJump
@export var red_spark_scene: PackedScene
@export var particles: GPUParticles2D
@export var shockwave: CollisionShape2D
@export var shockwave_sound: PolyphonicAudio
const SPEED: float = -1000
var phase: int
const LANDING_FRAME: int = 139
const FALLING_FRAME: int = 138
const LANDING_DURATION: float = 1
const SHOCKWAVE_ACTIVE_FOR_SECONDS: float = 0.5

func enter():
	var red_spark = red_spark_scene.instantiate()
	player.velocity.x = 0
	red_spark.global_position = player.global_position
	MetSys.get_current_room_instance().add_child(red_spark)
	animation.play("jump")
	phase = 0
	
func exit():
	pass

func Update(delta: float):
	if phase == 0 and player.velocity.y > 0:
		phase = 1
		animation.stop()
		player.sprite.frame = FALLING_FRAME
		
	if phase == 1 and player.is_on_floor():
		player.sprite.frame = LANDING_FRAME
		shockwave_sound.play_sound_effect_from_library("shockwave")
		generateIceExplosion()
		phase = 2
		get_tree().create_timer(LANDING_DURATION, false).timeout.connect(Transitioned.emit.bind(self, "idle"))

func Physics_Update(delta: float):
	pass

func applyJump() -> void:
	player.velocity.y = SPEED

func generateIceExplosion() -> void:
	particles.emitting = true
	shockwave.set_deferred("disabled", false)
	get_tree().create_timer(SHOCKWAVE_ACTIVE_FOR_SECONDS, false).timeout.connect(shockwave.set_deferred.bind("disabled", true))
	Global.camera.shake_strength = Global.camera.DEFAULT_RANDOM_STRENGTH
	Global.camera.apply_shake()
