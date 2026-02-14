extends State
class_name DeadPirateSneak
const SPEED: Vector2 = Vector2(200, -650)
var phase: int
@export var hitbox: CollisionShape2D
@export var trail: Sprite2D
@export var hurtbox: CollisionShape2D
var MIN_VANISH_DURATION: float = 0.5
var MAX_VANISH_DURATION: float = 1
const DISTANCE_FROM_PLAYER_AFTER_SPAWN: Vector2 = Vector2(170, -100)
const TWEEN_DURATION: float = 0.2
const TWEEN_DELAY: float = 0.1

func enter():
	animation.play("disappear")
	phase = 0
	
func exit():
	trail.visible = false
	player.velocity = Vector2.ZERO

func Update(delta: float):
	enemy_can_die()
	
	if not animation.is_playing() and phase == 0:
		player.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		hurtbox.set_deferred("disabled", true)
		hitbox.set_deferred("disabled", true)
		phase = 1
		get_tree().create_timer(randf_range(MIN_VANISH_DURATION, MAX_VANISH_DURATION), false).timeout.connect(func(): phase = 2)
		
	if phase == 2:
		player.global_position = Global.player.global_position + Vector2(DISTANCE_FROM_PLAYER_AFTER_SPAWN.x*Global.player.facing_position*(-1), DISTANCE_FROM_PLAYER_AFTER_SPAWN.y)
		can_turnaround_with_scale()
		fixPositionNotOutOfBounds()
		player.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
		player.velocity = Vector2(SPEED.x*player.facing_position, 0)
		hurtbox.set_deferred("disabled", false)
		player.hitbox.set_deferred("disabled", false)
		var reappear_tween: Tween = get_tree().create_tween()
		reappear_tween.tween_property(player.sprite, "modulate", Color.WHITE, TWEEN_DURATION).set_delay(TWEEN_DELAY)
		phase = 3
		
	if phase == 3 and player.is_on_floor():
		player.velocity = Vector2.ZERO
		animation.play("attack")
		phase = 4
		
	if phase == 4 and not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
	
func applyJumpSpeed() -> void:
	player.velocity = SPEED
	player.velocity.x *= player.facing_position

func fixPositionNotOutOfBounds() -> void:
	if player.global_position.x < Global.camera.limit_left+32:
		player.global_position.x = Global.player.global_position.x+DISTANCE_FROM_PLAYER_AFTER_SPAWN.x
		turn_around()
	elif player.global_position.x > Global.camera.limit_right-32:
		player.global_position.x = Global.player.global_position.x-DISTANCE_FROM_PLAYER_AFTER_SPAWN.x
		turn_around()
