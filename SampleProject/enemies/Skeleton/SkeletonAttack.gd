extends State
class_name SkeletonAttack
@export var hitbox_iframe = CollisionShape2D
@export var bone_scene: PackedScene
@export var bone_speed: Vector2

func enter():
	animation.play("throw", -1, 1)
	player.velocity.x = 0
	
func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "moving") 
		
func Physics_Update(delta: float):
	enemy_can_die()
		
func throw_bone():
	var bones_thrown = 1
	if Global.game.difficulty == Global.game.Difficulty.CRAZY and bone_speed.x < 100:
		bones_thrown = 3
	sound.play_sound_effect_from_library("throw")
	for i in range(0, bones_thrown):
		var bone = bone_scene.instantiate()
		get_parent().get_parent().get_parent().add_child(bone)
		bone.sprite.scale.x *= player.facing_position
		bone.hitbox_iframe.scale.x *= player.facing_position
		bone.hurtbox.scale.x *= player.facing_position
		bone.global_position = player.global_position - Vector2(-20*player.facing_position, 40)
		bone.linear_velocity.x = bone_speed.x * player.facing_position
		if bone_speed.x < 100:
			bone.linear_velocity.x *= randi_range(1, 4)
		bone.linear_velocity.y = bone_speed.y
		bone.stats.thrower_ATK = player.stats.ATK
		bone.thrower = player
	
