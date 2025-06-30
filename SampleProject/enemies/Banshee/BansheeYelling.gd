extends State
class_name BansheeYelling
@export var duration: Timer
@export var afterimage_animation: AnimationPlayer

func enter():
	sound.play_sound_effect_from_library("yell")
	animation.play("yelling", -1, 1)
	afterimage_animation.play("yelling")
	player.yelling_hitbox.get_child(0).disabled = false
	duration.start()

func exit():
	afterimage_animation.play("RESET")
	player.yelling_hitbox.get_child(0).disabled = true

func Update(delta: float):
	enemy_can_die()

func _on_duration_timeout() -> void:
	if player.stats.HP > 0:
		animation.play("stop_yelling")
		player.yelling_hitbox.get_child(0).disabled = true
		afterimage_animation.play("RESET")
		await animation.animation_finished
		Transitioned.emit(self, "moving")
