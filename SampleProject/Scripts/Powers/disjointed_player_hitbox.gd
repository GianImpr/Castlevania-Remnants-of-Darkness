extends PlayerHitbox
class_name DisjointedPlayerHitbox
@export var extra_base_damage: int
@export var damage_multiplier: float
@export var magical: bool

func _process(delta: float) -> void:
	super(delta)
	if self is AguniLaurelHitbox:
		return
		
	if Global.player != null and Global.player.sprite.weapon != null and Global.player.sprite.weapon.hitbox != null:
		base_attribute = Global.player.sprite.weapon.hitbox.base_attribute
	else:
		base_attribute = [Global.Attribute.SLASH]
