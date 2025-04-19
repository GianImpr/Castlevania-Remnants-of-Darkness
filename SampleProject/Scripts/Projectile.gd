extends Node
class_name Projectile
@export var base_damage: int
@export var fixed_damage: bool
@export var destructible: bool
@export var destroy_on_contact: bool
@export var magical: bool
@export var effect_on_destroy: bool
@export var chip_damage: int = 0
@export var attribute: Global.Attribute = Global.Attribute.HIT
var thrower_ATK: int = 0

func calculate_damage(body, multiplier: float = 1) -> int:
	var damage
	if magical:
		damage = max(base_damage + thrower_ATK - body.stats.Stats["RES"]/2, 1) * multiplier
	else:
		damage = max(base_damage + thrower_ATK - body.stats.Stats["DEF"]/2, 1) * multiplier
		
	if body.isGuarding():
		damage = damage + chip_damage
		if body.isPerfectGuarding():
			body.stats.Stats["MP"] = min(body.stats.Stats["MMP"], body.stats.Stats["MP"]+floor(damage/10)+10)
			body.heal_innocent(floor(damage/10)+1)
			body.stats.Stats["Guard"] = 3
			return 0
		if damage < body.stats.Stats["MHP"]/10 and body.stats.Stats["Guard"] > 1:
			damage = 0
		elif damage >= body.stats.Stats["MHP"]/10 and body.stats.Stats["Guard"] > 1:
			damage = min(damage*0.2, body.stats.Stats["HP"]-1)
		elif body.stats.Stats["Guard"] == 1:
			damage *= 0.6
		body.stats.Stats["Guard"] -= 1
	else:
		body.applyHitEffect(attribute)
	return damage
		
func apply_damage(body, damage):
	body.damage_popup.popup(damage, 0)
	body.stats.Stats["HP"] -= damage
	body.is_hurt = true
