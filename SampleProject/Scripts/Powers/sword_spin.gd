extends PlayerProjectile
class_name SwordSpin
@export var sword_sprite: Sprite2D

## Updates the rotating sprite to match the currently equipped sword.
func updateSprite() -> void:
	sword_sprite.texture = Global.player.sprite.weapon.boomerang.texture
