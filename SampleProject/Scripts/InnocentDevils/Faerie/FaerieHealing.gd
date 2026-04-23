extends State
class_name FaerieHealing
@export var refreshing_air_scene: PackedScene
@export var poison_powder_scene: PackedScene
@export var magic_particles: CPUParticles2D
var skill_id: int
var skills: Array[Callable] = [
	heal,
	refreshingAir,
	timeHeal,
	errorSkill,
	resistFireIce,
	poisonPowder
]

func enter():
	player.lock_current_skill = true
	player.velocity = Vector2(0, 0)
	skill_id = player.current_skill
	animation.play("heal")
	player.stats.Stats["Hearts"] -= player.stats.skills[skill_id].cost

func exit():
	player.lock_current_skill = false

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
		
func Physics_Update(delta: float):
	pass
	
func heal() -> void:
	setSoundAndParticles("heal_effect", Color(0,1,0))
	Global.player.heal(49+player.stats.Stats["INT"]/3)

func refreshingAir() -> void:
	setSoundAndParticles("heal_effect", Color(0.3,0,1))
	Global.player.stats.status[Global.player.stats.Status.REFRESHING_AIR] = 15
	var refreshing_air = refreshing_air_scene.instantiate()
	Global.player.add_child(refreshing_air)
	refreshing_air.position.y += 30

func timeHeal() -> void:
	setSoundAndParticles("heal_effect", Color(0.3,0.7,1))
	Global.player.applyTimeHeal()
	
func resistFireIce() -> void:
	setSoundAndParticles("heal_effect", Color(0.8,0,7))
	Global.player.stats.status[Global.player.stats.Status.RESIST_FIRE_ICE] = 30
	
func poisonPowder() -> void:
	const POISON_POWDER_OFFSET: Vector2 = Vector2(57, 52)
	setSoundAndParticles("heal_effect", Color(0.3,0.6,0.5))
	var poison_powder = poison_powder_scene.instantiate()
	poison_powder.global_position = player.global_position
	poison_powder.global_position.x += POISON_POWDER_OFFSET.x*player.facing_position
	poison_powder.global_position.y += POISON_POWDER_OFFSET.y
	MetSys.get_current_room_instance().add_child(poison_powder)
	
func setSoundAndParticles(sound_name: String, color: Color) -> void:
	magic_particles.self_modulate = color
	sound.play_sound_effect_from_library(sound_name)
	
func performSkill():
	skills[skill_id].call()

func errorSkill():
	printerr("This slot should not be used.")
