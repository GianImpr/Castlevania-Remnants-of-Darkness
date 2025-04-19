extends State
class_name DullahanThrowHead
var phase: int
@export var head_light: PointLight2D
@export var fangs_number: int
@export var fangs_timer: Timer
var summoned_fangs: int

func enter():
	animation.play("teleport_center")
	phase = 0
	summoned_fangs = 0
	
func exit():
	pass
	
func Update(delta: float):
	if not animation.is_playing() and phase == 0:
		animation.play("throw_head")
		await animation.animation_finished
		_chooseAttack()
		phase = 1
		
	if phase == 2 and not animation.is_playing():
		if Global.game.difficulty == Global.game.Difficulty.CRAZY and randi_range(0,1) == 0:
			summoned_fangs = 0
			_chooseAttack()
			phase = 1
		else:
			animation.play_backwards("catch_head")
			await animation.animation_finished
			Transitioned.emit(self, "idle")
		
func _chooseAttack() -> void:
	var possible_attacks = 0
	if player.phase_two:
		possible_attacks = 1
	if randi_range(0, possible_attacks) == 1:
		await _enlight_head(Color(0, 1, 1))
		fangs_timer.start()
	else:
		await _enlight_head(Color(1, 0, 1))
		sound.get_child(0).play_sound_effect_from_library("throw_projectiles")
		player.spawnProjectiles()
		phase = 2

func _enlight_head(color: Color) -> void:
	var tween = get_tree().create_tween()
	sound.get_child(0).play_sound_effect_from_library("head_light")
	head_light.color = color
	tween.tween_property(head_light, "energy", 15, 0.5)
	await tween.finished
	tween = get_tree().create_tween()
	tween.tween_property(head_light, "energy", 0, 0.5)
	await tween.finished


func _on_fangs_timeout() -> void:
	player.spawnFang()
	summoned_fangs += 1
	if summoned_fangs == fangs_number:
		fangs_timer.stop()
		phase = 2
