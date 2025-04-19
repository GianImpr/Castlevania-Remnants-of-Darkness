extends State
class_name AxeArmorAttack
@export var hitbox_iframe: CollisionShape2D
@export var axe_scene: PackedScene
@export var axe_speed: Vector2
var throw_type: int

func enter():
	throw_type = randi_range(0, 1)
	if throw_type == 1:
		animation.play("throw_high", -1, 1)
	else:
		animation.play("throw_low", -1, 1)
	player.velocity.x = 0
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "respawn_axe") 
		
func Physics_Update(delta: float):
	enemy_can_die()
		
func throw_axe():
	sound.play_sound_effect_from_library("swing")
	var axe = axe_scene.instantiate()
	get_parent().get_parent().get_parent().add_child(axe)
	axe.sprite.scale.x *= player.facing_position
	axe.hitbox_iframe.scale.x *= player.facing_position
	axe.hurtbox.scale.x *= player.facing_position
	axe.global_position = player.global_position - Vector2(-30*player.facing_position, -25+60*int(throw_type))
	axe.linear_velocity.x = axe_speed.x * player.facing_position
	axe.direction = player.facing_position
	axe.linear_velocity.y = axe_speed.y
	axe.stats.thrower_ATK = player.stats.ATK
	
