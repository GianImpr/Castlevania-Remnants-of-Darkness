extends State
class_name HectorEarthquake
var can_perfect_guard: bool = false
@export var earthquake_scene: PackedScene
const EARTHQUAKE_SPAWNING_OFFSET: Vector2 = Vector2(0,60)
const JUMP_HEIGHT: float = -700
const STOP_ANIM_AT_SECONDS: float = 0.2
const FINAL_FRAME: int = 289
var phase: int
const TRANSITION_DELAY: float = 0.7
const AXE_SWUNG_ANIM_TIME: float = 0.4

func enter():
	animation.play("air_attack_axe")
	player.sprite.weapon.play_air()
	player.velocity.y = JUMP_HEIGHT
	phase = 0
	player.playSpecialAttackEffect()
	remove_momentum()
	
func exit():
	pass

func Update(delta: float):
	if phase == 0 and animation.current_animation_position >= STOP_ANIM_AT_SECONDS:
		animation.pause()
		player.sprite.weapon.animation.pause()
		
	if phase == 0 and player.velocity.y > 0:
		animation.play()
		player.sprite.weapon.animation.play()
		phase = 1
		
	if phase == 1 and player.is_on_floor():
		animation.stop()
		player.sprite.frame = FINAL_FRAME
		if player.sprite.weapon.animation.current_animation_position < AXE_SWUNG_ANIM_TIME:
			player.sprite.weapon.animation.seek(AXE_SWUNG_ANIM_TIME)
		generateEarthquake()
		phase = 2
		get_tree().create_timer(TRANSITION_DELAY, false).timeout.connect(Transitioned.emit.bind(self, "idle"))

func Physics_Update(delta: float):
	if phase == 1:
		player.velocity += player.get_gravity() * delta #add extra gravity

func generateEarthquake() -> void:
	Global.camera.random_strength = Global.camera.DEFAULT_RANDOM_STRENGTH
	Global.camera.apply_shake()
	var earthquake = earthquake_scene.instantiate()
	earthquake.global_position = player.global_position
	earthquake.global_position.x += (EARTHQUAKE_SPAWNING_OFFSET.x * player.facing_position)
	earthquake.global_position.y += EARTHQUAKE_SPAWNING_OFFSET.y
	MetSys.get_current_room_instance().add_child(earthquake)
