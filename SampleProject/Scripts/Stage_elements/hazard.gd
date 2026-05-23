extends StaticBody2D
class_name Hazard
@export var area: Area2D
@export var base_power: int = 0
@export_range(0,100,1,"suffix:%") var percent_damage: int = 0
@export_range(0.5,3,0.1,"suffix:s") var iframe_duration: float = 1
@export var ignore_defense: bool = false

func _ready() -> void:
	area.area_entered.connect(applyDamage)
	
func applyDamage(body_area: Area2D) -> void:
	var body: Node2D = body_area.get_parent()
	var power: int = base_power + percent_damage*body.stats.Stats["MHP"]/100
	if ignore_defense:
		power += body.stats.Stats["DEF"]/2
	var chip_damage: int = power/3
	const MULTIPLIER: int = 1
	var damage: int = body.stats.calculateDamageTaken(power, MULTIPLIER, chip_damage, true, Global.Attribute.HIT, true)
	body.damage_popup.popup(damage, 0)
	body.stats.Stats["HP"] = max(body.stats.Stats["HP"]-damage, 0)
	body.is_hurt = true
	area.get_child(0).set_deferred("disabled", true)
	get_tree().create_timer(iframe_duration, false).timeout.connect(area.get_child(0).set_deferred.bind("disabled", false))
