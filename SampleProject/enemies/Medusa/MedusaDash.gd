extends State
class_name MedusaDash
@export var red_spark_scene: PackedScene
var mini_backdash_tween: Tween
var dash_speed_tween: Tween
const BACKDASH_SPEED: float = 150
const BACKDASH_DURATION: float = 1
const DASH_SPEED: float = 1200
const DASH_DURATION: float = 1.5
const sword_sounds: Array[String] = ["sword_1", "sword_2"]

func enter():
	if Global.player.stats.current_status == Global.player.stats.Ailment.STONE:
		sound.play_sound_effect_from_library("clever")
	else:
		sound.play_sound_effect_from_library("lock_in")
		
	animation.play("dash")
	var red_spark = red_spark_scene.instantiate()
	player.add_child(red_spark)
	mini_backdash_tween = get_tree().create_tween()
	player.velocity.x = BACKDASH_SPEED * player.facing_position * (-1)
	mini_backdash_tween.tween_property(player, "velocity", Vector2.ZERO, BACKDASH_DURATION)
	
func exit():
	pass

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass

func applyDashSpeed() -> void:
	sound.play_sound_effect_from_library(sword_sounds.pick_random())
	dash_speed_tween = get_tree().create_tween()
	player.velocity.x = DASH_SPEED * player.facing_position
	dash_speed_tween.tween_property(player, "velocity", Vector2.ZERO, DASH_DURATION)
