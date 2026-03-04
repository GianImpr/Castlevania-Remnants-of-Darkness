extends State
class_name HectorShredder
var can_perfect_guard: bool = false
@export var shredder_scene: PackedScene
const SHREDDER_SPAWNING_OFFSET: Vector2 = Vector2(45,-5)
const SPIN_FRAME: int = 129
const START_ANIMATION_FROM_SECONDS: float = 0.2
var phase: int
const DURATION_AT_FULL_FOCUS_IN_SECONDS: float = 10
var focus_consumption_tween: Tween
var shredder: SwordShredder
var finished: bool

func enter():
	animation.stop()
	finished = false
	focus_consumption_tween = get_tree().create_tween()
	focus_consumption_tween.tween_property(player.stats, "Stats:FP", 0, DURATION_AT_FULL_FOCUS_IN_SECONDS*player.stats.Stats["FP"]/player.stats.Stats["MFP"])
	focus_consumption_tween.finished.connect(func(): finished = true)
	player.sprite.frame = SPIN_FRAME
	player.playSpecialAttackEffect()
	generateShredder()
	remove_momentum()
	
func exit():
	if shredder != null:
		shredder.queue_free()
		
	focus_consumption_tween.kill()

func Update(delta: float):
	check_is_hurt()
	can_fall(false)
	
	if not player.sprite.frame == SPIN_FRAME and not finished:
		player.sprite.frame = SPIN_FRAME
	
	if not Input.is_action_pressed("circle") and not finished:
		finished = true
		
	if finished and shredder != null:
		shredder.queue_free()
		animation.play("throw")
		animation.seek(START_ANIMATION_FROM_SECONDS)
		
	if not animation.is_playing() and finished:
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass

func generateShredder() -> void:
	shredder = shredder_scene.instantiate()
	shredder.global_position = player.global_position
	shredder.global_position.x += (SHREDDER_SPAWNING_OFFSET.x * player.facing_position)
	shredder.global_position.y += SHREDDER_SPAWNING_OFFSET.y
	MetSys.get_current_room_instance().add_child(shredder)
