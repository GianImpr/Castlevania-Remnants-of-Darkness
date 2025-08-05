extends PlayerHitbox
class_name DisjointedPlayerHitbox
@export var extra_base_damage: int
@export var damage_multiplier: float
@export_range(0, 1, 0.01, "suffix:s") var iframes_duration: float
@export var magical: bool

func _process(delta: float) -> void:
	super(delta)
	
# Calculates the base damage of the move
func calculateDamage(body: Node2D) -> int:
	set_deferred("monitoring", false)
	get_tree().create_timer(iframes_duration).timeout.connect(func(): monitoring = true)
	if magical:
		return max((player.stats.Stats["INT"]+extra_base_damage)*damage_multiplier - body.stats.RES/2, 1)
	else:
		return max((player.stats.Stats["ATK"]+extra_base_damage)*damage_multiplier - body.stats.DEF/2, 1)
