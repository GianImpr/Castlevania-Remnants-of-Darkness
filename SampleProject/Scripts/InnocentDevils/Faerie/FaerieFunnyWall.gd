extends State
class_name FaerieFunnyWall
@export var wings: AnimationPlayer
var destination: Vector2
var phase: int = 0
@export var idle_duration: Timer

func enter():
	animation.play("move_start", -1, 1.3)
	wings.play("normal")
	destination = player.funny_wall_destination
	phase = 0
	
func Update(delta: float):
	if (not animation.is_playing() or animation.current_animation != "move_start") and phase == 0:
		determineAnimation()
		phase = 1
		
	if abs(player.position - destination).length_squared() <= Vector2(50, 50).length_squared() and phase == 1:
		animation.play("stopping", -1, 1.3)
		wings.play("normal")
		player.velocity *= 0.4
		phase = 2
		
	if phase == 2 and not animation.is_playing():
		animation.play("idle")
		idle_duration.start()
		wings.play("normal")
		sound.play_sound_effect_from_library("funny_wall")
		
	if phase == 3 and animation.current_animation != "heal":
		animation.play("open", -1, 2)
		wings.play("normal")
		phase = 4
		
	if phase == 4 and not animation.is_playing():
		Transitioned.emit(self, "idle")
		
func Physics_Update(delta: float):
	player.velocity = Vector2(destination.x - player.position.x, destination.y - player.position.y) / 1
	if destination.x < player.position.x*player.facing_position:
		turn_around()

func determineAnimation():
	if abs(player.velocity.y) > abs(player.velocity.x) and abs(player.velocity.x) < 300 and player.velocity.y > 0 and animation.current_animation != "dropping":
		animation.play("dropping", -1, 2)
		wings.play("normal")
	elif abs(player.velocity.y) > abs(player.velocity.x) and abs(player.velocity.x) < 300 and player.velocity.y < 0 and animation.current_animation != "rising":
		animation.play("rising", -1, 1)
		wings.play("normal")
	elif abs(player.velocity.y) < abs(player.velocity.x) and animation.current_animation != "running":
		animation.play("running", -1, 2)
		wings.play("running")
		
func _on_idle_duration_timeout() -> void:
	phase = 3
	
func trigger_event():
	sound.play_sound_effect_from_library("heal3")
	Global.player.stats.event_flags[player.wall_event_id] = true
