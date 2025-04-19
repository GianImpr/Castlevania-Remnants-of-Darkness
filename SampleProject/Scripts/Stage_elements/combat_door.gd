extends StaticBody2D
class_name CombatDoor
@export var animation: AnimationPlayer
@export var open_delay: Timer
@export var close_delay: Timer
@export var combat_door_texture: CompressedTexture2D
@export var boss_door_texture: CompressedTexture2D
@export var door_sprite: Sprite2D
@export var seal_sprite: Sprite2D

func _ready():
	seal_sprite.visible = get_parent().boss_door
	if get_parent().boss_door:
		door_sprite.texture = boss_door_texture
	else:
		door_sprite.texture = combat_door_texture
	if Global.player.stats.combat_flags[get_parent().combat_flag_id]:
		get_parent().queue_free()
	if get_parent().should_close:
		if not Global.player.stats.combat_flags[get_parent().combat_flag_id]:
			Global.player.global_position.x += 40
		if not Global.player.stats.combat_flags[get_parent().combat_flag_id]:
			Global.player.freeze()
		position.y = -128
		close_delay.start()
	else:
		position.y = 0

func _physics_process(delta: float) -> void:
	if Global.player.stats.combat_flags[get_parent().combat_flag_id] and open_delay.is_stopped() and position.y == 0:
		open_delay.start()

# Open door when Hector is touching them to enter the room
func _on_detection_area_body_entered(body: Node2D) -> void:
	if not get_parent().should_close:
		if get_parent().boss_door:
			animation.play("open_boss")
		else:
			animation.play("open")
		await animation.animation_finished
		get_parent().queue_free()

# Open doors a bit after the fight is over
func _on_animation_delay_timeout() -> void:
	if get_parent().boss_door:
		animation.play("open_boss")
	else:
		animation.play("open")
	await animation.animation_finished
	get_parent().queue_free()

# Close door when entered
func _on_close_delay_timeout() -> void:
	Global.player.unfreeze()
	if get_parent().boss_door:
		animation.play("close_boss")
	else:
		animation.play("close")
