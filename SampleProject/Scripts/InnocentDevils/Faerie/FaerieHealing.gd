extends State
class_name FaerieHealing
@export var wings: AnimationPlayer
@export var refreshing_air_scene: PackedScene
@export var magic_particles: CPUParticles2D
var skill_id: int
var skills: Array[Callable] = [
	heal,
	refreshingAir
]

func enter():
	player.velocity = Vector2(0, 0)
	skill_id = player.current_skill
	animation.play("heal", -1, 2)
	wings.play("normal")
	player.stats.Stats["Hearts"] -= player.stats.skills[skill_id].cost
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
		
func Physics_Update(delta: float):
	pass
	
func heal() -> void:
	setSoundAndParticles("heal_effect", Color(0,1,0))
	Global.player.heal(50)

func refreshingAir() -> void:
	setSoundAndParticles("heal_effect", Color(0.3,0,1))
	Global.player.stats.status[Global.player.stats.Status.REFRESHING_AIR] = 900
	var refreshing_air = refreshing_air_scene.instantiate()
	Global.player.add_child(refreshing_air)
	refreshing_air.position.y += 30
	
func setSoundAndParticles(sound_name: String, color: Color) -> void:
	magic_particles.self_modulate = color
	var voice_clip = "heal" + str(randi_range(1,3))
	sound.play_sound_effect_from_library(voice_clip)
	sound.play_sound_effect_from_library(sound_name)
	
func performSkill():
	skills[skill_id].call()
