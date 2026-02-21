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

func calculate_damage(body, multiplier: float = 1, knockback: bool = false) -> int:
	const CONFIDENCE_RING_MULTIPLIER: float = 1.3
	const ENFEEBLE_DAMAGE_MULTIPLIER: float = 1.3
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
			TrainingSettings.spawnTrainingHeart(TrainingMode.Training.GUARD)
			return 0
		if (damage < body.stats.Stats["MHP"]/10 or TrainingSettings.cur_challenge == TrainingMode.Training.GUARD) and body.stats.Stats["Guard"] > 1 and not guard_break:
			TrainingSettings.spawnTrainingHeart(TrainingMode.Training.GUARD)
			if not Global.player.stats.itemEquipped(Headgear.Headgears.IMPERVIOUS_HELMET, "head"):
				body.stats.Stats["Guard"] -= 1
			return 0
		elif damage >= body.stats.Stats["MHP"]/10 and body.stats.Stats["Guard"] > 1 and not guard_break:
			damage = min(damage*0.1, body.stats.Stats["HP"]-1)
		elif (body.stats.Stats["Guard"] == 1 and not Global.player.stats.itemEquipped(Headgear.Headgears.IMPERVIOUS_HELMET, "head")) or guard_break:
			damage *= 0.6
		if not guard_break:
			if not Global.player.stats.itemEquipped(Headgear.Headgears.IMPERVIOUS_HELMET, "head"):
				body.stats.Stats["Guard"] -= 1
		else:
			body.stats.Stats["Guard"] = 0
		
	else:
		body.knockback = knockback
		body.applyHitEffect(attribute)
	
	if not body.isGuarding() or body.stats.Stats["Guard"] == 0:
		match attribute:
			Global.Attribute.STONE:
				body.petrify()
			Global.Attribute.CURSE:
				body.curse()
			Global.Attribute.POISON:
				body.poison()
			Global.Attribute.ENFEEBLE:
				body.enfeeble()
		
	if body.isGuarding() and Global.game.difficulty == Game.Difficulty.SIMPLIFIED:
		if guard_break:
			damage = min(damage*0.6, body.stats.Stats["HP"]/10)
		else:
			damage = 0
	
	if body.stats.current_status == Global.player.stats.Ailment.STONE:
		damage *= 2
		
	if body.stats.accessoryEquipped(Accessory.Accessories.CONFIDENCE_RING):
		damage *= CONFIDENCE_RING_MULTIPLIER
		
	if body.stats.status[body.stats.Status.ENFEEBLE] > 0:
		damage *= ENFEEBLE_DAMAGE_MULTIPLIER
		
	if Global.screen == Global.ScreenType.TRAINING:
		return ceil(body.stats.Stats["MHP"] * TrainingSettings.damage_upon_hit / 100)

	return damage
		
func apply_damage(body, damage):
	body.damage_popup.popup(damage, 0)
	body.stats.Stats["HP"] -= damage
	body.is_hurt = true
	if body.stats.accessoryEquipped(Accessory.Accessories.STOIC_BELT) and not body.isGuarding() and damage < body.stats.Stats["MHP"]*0.07:
		body.is_hurt = false
