extends State
class_name HectorSneakAttack
var can_perfect_guard: bool = false
@export var outline_scene: PackedScene
var initial_flip_h: bool
var target: Enemy
const DEFAULT_DISTANCE_TRAVEL: Vector2 = Vector2(150, 0)
const OFFSET_FROM_ENEMY_POSITION: Vector2 = Vector2(30, -10)

func enter():
	target = player.closestEnemy()
	player.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	initial_flip_h = player.sprite.flip_h
	animation.play("sneak_attack")
	voice.play_sound_effect_from_library("heavy_attack_3")
	player.playSpecialAttackEffect()
	remove_momentum()
	

func Update(delta: float):
	if not animation.is_playing():
		Transitioned.emit(self, "idle")
	
func Physics_Update(delta: float):
	pass

func warpToClosestEnemy() -> void:
	if not target:
		Global.player.sprite.position = DEFAULT_DISTANCE_TRAVEL*player.facing_position
	else:
		Global.player.sprite.position = (target.getHurtbox().global_position - Global.player.global_position) / 2
		Global.player.sprite.position.x += OFFSET_FROM_ENEMY_POSITION.x*player.facing_position
		Global.player.sprite.position.y += OFFSET_FROM_ENEMY_POSITION.y
	player.sprite.flip_h = not initial_flip_h
	player.facing_position = -1 if player.sprite.flip_h else 1


func warpBack() -> void:
	Global.player.sprite.position = Vector2.ZERO
	player.sprite.flip_h = initial_flip_h
	player.facing_position = -1 if player.sprite.flip_h else 1
	player.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED

func useWeapon() -> void:
	sound.play_sound_effect_from_library(get_attack_sound())
	swingWeapon(AttackType.AIR)
