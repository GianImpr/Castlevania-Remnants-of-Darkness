extends State
class_name DeadPirateHopSwing
const SPEED: Vector2 = Vector2(200, -450)
var phase: int
@export var sword_hitbox: CollisionShape2D
@export var trail: Sprite2D
@export var red_spark_scene: PackedScene
const PHASE_INCREMENT_DELAY_SECONDS: float = 0.2
const INITIAL_DELAY: float = 0.7

func enter():
	animation.play("idle")
	phase = 0
	var red_spark = red_spark_scene.instantiate()
	red_spark.global_position = player.global_position
	MetSys.get_current_room_instance().add_child(red_spark)
	get_tree().create_timer(INITIAL_DELAY, false).timeout.connect(startPhase)
	player.sword_guard_break = true
	
func exit():
	sword_hitbox.set_deferred("disabled", true)
	trail.visible = false
	player.velocity = Vector2.ZERO
	player.sword_guard_break = false

func Update(delta: float):
	enemy_can_die()
	
	if phase == 1 and not animation.is_playing():
		player.velocity = SPEED
		player.velocity.x *= player.facing_position
		get_tree().create_timer(PHASE_INCREMENT_DELAY_SECONDS, false).timeout.connect(func(): phase = 2)
		
	if phase == 2 and player.is_on_floor():
		player.velocity = Vector2.ZERO
		animation.play("attack")
		phase = 3
		
	if phase == 3 and not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass

func startPhase() -> void:
	phase = 1
	animation.play("jump")
