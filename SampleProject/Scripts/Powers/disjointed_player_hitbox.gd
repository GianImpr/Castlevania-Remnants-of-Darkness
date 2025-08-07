extends PlayerHitbox
class_name DisjointedPlayerHitbox
@export var extra_base_damage: int
@export var damage_multiplier: float
@export var magical: bool

func _process(delta: float) -> void:
	super(delta)
	
# Calculates the base damage of the move
func calculateDamage(body: Node2D) -> int:
	if magical:
		return max((player.stats.Stats["INT"]+extra_base_damage)*damage_multiplier - body.stats.RES/2, 1)
	else:
		return max((player.stats.Stats["ATK"]+extra_base_damage)*damage_multiplier - body.stats.DEF/2, 1)
