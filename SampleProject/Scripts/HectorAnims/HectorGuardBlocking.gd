extends State
class_name HectorGuardBlocking
@export var recoil_speed: float
var can_perfect_guard: bool = false
const DECELERATION: float = 0.9
const FEATHER_BOOTS_BOOST: float = 150

func enter():
	player.velocity.x = recoil_speed * player.facing_position * (-1)
	if player.stats.itemEquipped(Legs.Leg.FEATHER_BOOTS, "legs"):
		player.velocity.x = player.velocity.x + FEATHER_BOOTS_BOOST * player.facing_position * (-1)
	animation.play("guarding", -1, 1.7)
	sound.play_sound_effect_from_library("block")
	
	if player.stats.canApplySkill(Skill.Skills.AWARENESS):
		player.focus_gain_duration.start()
		
	if player.stats.itemEquipped(Artifact.Artifacts.STONE_OF_ALCHEMY, "artifact"):
		player.activateStoneOfAlchemy()
		

	
func exit():
	player.is_hurt = false
	player.applyMercyInvincibility(Global.player.AFTER_GUARD_MERCY_INVINCIBILITY_DURATION, false)
	
func Update(delta: float):
	if player.stats.canApplySkill(Skill.Skills.GUARD_STANCE):
		can_attack()
	
func Physics_Update(delta: float):
	can_die()
	can_fall(true)
	
	if animation.is_playing():
		player.velocity.x *= DECELERATION
	else:
		player.velocity.x = 0
		Transitioned.emit(self, "guard")
