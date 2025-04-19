extends State
class_name BonePillarShoot
@export var fireball_scene: PackedScene
@export var fireball_origin: Vector2

func enter():
	animation.play("shoot", -1, 1.3)
	sound.play_sound_effect_from_library("shoot")

func Update(delta):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

	enemy_can_die(false)

func shootFireball():
	var fireball_position: Vector2 = Vector2(fireball_origin.x * player.facing_position, fireball_origin.y)
	var fireball = fireball_scene.instantiate()
	fireball.direction = player.facing_position
	fireball.stats.thrower_ATK = player.stats.ATK
	fireball.sprite.scale.x *= player.facing_position * (-1)
	get_parent().get_parent().get_parent().add_child(fireball)
	fireball.global_position = player.global_position + fireball_position
