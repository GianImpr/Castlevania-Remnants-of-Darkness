extends PlayerHitbox
class_name DisjointedPlayerHitbox
@export var extra_base_damage: int
@export var damage_multiplier: float
@export var iframes: int
var cur_frame: int = 0

func _process(delta: float) -> void:
	super(delta)
	cur_frame += 1
	monitoring = not (cur_frame % iframes == 0)
	
# Calculates the base damage of the move
func calculateDamage(body: Node2D) -> int:
	return max((player.stats.Stats["ATK"]+extra_base_damage)*damage_multiplier - body.stats.DEF/2, 1)
