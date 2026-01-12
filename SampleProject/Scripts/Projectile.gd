extends Node
class_name Projectile
@export var base_damage: int
@export var fixed_damage: bool
@export var destructible: bool
@export var destroy_on_contact: bool
@export var destroy_on_block: bool
@export var magical: bool
@export var effect_on_destroy: bool
@export var chip_damage: int = 0
@export var attribute: Global.Attribute = Global.Attribute.HIT
@export var guard_break: bool = false
var thrower_ATK: int = 0

func calculate_damage(body, multiplier: float = 1) -> int:
	var damage
	if magical:
		damage = max(base_damage + thrower_ATK - body.stats.Stats["RES"]/2, 1) * multiplier
	else:
		damage = max(base_damage + thrower_ATK - body.stats.Stats["DEF"]/2, 1) * multiplier
		
	if body.isGuarding():
		if destroy_on_block:
			get_parent().destroy()
		damage = damage + chip_damage
		if body.isPerfectGuarding():
			body.stats.Stats["MP"] = min(body.stats.Stats["MMP"], body.stats.Stats["MP"]+floor(damage/10)+10)
			body.heal_innocent(floor(damage/10)+1)
			body.stats.Stats["Guard"] = 3
			TrainingSettings.spawnTrainingHeart(TrainingMode.Training.PERFECT_GUARD)
			return 0
		if damage < body.stats.Stats["MHP"]/10 and body.stats.Stats["Guard"] > 1:
			damage = 0
		elif damage >= body.stats.Stats["MHP"]/10 and body.stats.Stats["Guard"] > 1 and not guard_break:
			damage = min(damage*0.1, body.stats.Stats["HP"]-1)
			TrainingSettings.spawnTrainingHeart(TrainingMode.Training.GUARD)
		elif body.stats.Stats["Guard"] == 1 or guard_break:
			damage *= 0.6
		if not guard_break:
			body.stats.Stats["Guard"] -= 1
		else:
			body.stats.Stats["Guard"] = 0
		
	else:
		body.applyHitEffect(attribute)
		
	if body.isGuarding() and Global.game.difficulty == Game.Difficulty.SIMPLIFIED:
		if guard_break:
			damage = min(damage*0.6, body.stats.Stats["HP"]/10)
		else:
			damage = 0
	
	if body.stats.current_status == Global.player.stats.Ailment.STONE:
		damage *= 2
		
	if Global.screen == Global.ScreenType.TRAINING:
		return ceil(body.stats.Stats["MHP"] * TrainingSettings.damage_upon_hit / 100)

	return damage
		
func apply_damage(body, damage):
	body.damage_popup.popup(damage, 0)
	body.stats.Stats["HP"] -= damage
	body.is_hurt = true
