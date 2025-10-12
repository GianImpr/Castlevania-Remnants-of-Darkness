extends Marker2D
class_name DamagePopup

@export var damage_node: PackedScene

func popup(dmg: int, type: int, offset: Vector2 = Vector2(0,0)):
	var damage = damage_node.instantiate()
	damage.position = global_position + offset
	damage.damage_value = dmg
	damage.type = type
	
	get_tree().current_scene.add_child(damage)
