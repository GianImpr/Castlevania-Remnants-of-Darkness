extends Node2D
@export var power: int
@export var multiplier: float
@export var cost: int
@export var attribute: Global.Attribute
@export var icicle_scene: PackedScene
@export var animation: AnimationPlayer
@export var sound: PolyphonicAudio
@export var hit_collision_scene: PackedScene
@export var hitbox: CollisionShape2D
@export var sprite: Sprite2D

var activated: bool = true

func _ready():
	visible = false
	
func _process(delta: float) -> void:
	activated = Global.player.isGuarding() and Global.player.stats.Stats["MP"] >= cost and Global.player.stats.equipment["relic"] == 1 and Global.player.enabled_magic
	
	if animation.current_animation == "appear" or not animation.is_playing():
		update_direction()
	
	if (not animation.is_playing() or animation.current_animation == "vanish") and activated:
		visible = true
		sound.play_sound_effect_from_library("open")
		animation.play("appear")
		hitbox.get_parent().monitoring = true
		
	if animation.is_playing() and not activated and not animation.current_animation == "vanish":
		sound.play_sound_effect_from_library("close")
		animation.play("vanish")
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Candle:
		return
	if body is UkobackFireball:
		body.destroy()
		Global.player.stats.Stats["MP"] -= cost/5
	if body is KamikazeRaven:
		body.explode()
		Global.player.stats.Stats["MP"] -= cost/2
	if body is RigidBody2D and Global.player.stats.Stats["MP"] >= cost:
		if not body.stats.destructible:
			return
		if body.stats.effect_on_destroy:
			create_effects(body)
		body.destroy()
		animation.play("contact")
		sound.play_sound_effect_from_library("create_icicle")
		Global.player.stats.Stats["MP"] -= cost
		var icicle = icicle_scene.instantiate()
		if sprite.flip_h:
			icicle.position *= -1
			icicle.scale.x *= -1
			icicle.direction = -1
		icicle.power = power + multiplier*Global.player.stats.Stats["INT"]
		if Global.player.stats.findItem(Skill.Skills.CYAN_ORB, Global.player.stats.skill_inventory):
			icicle.power *= 1.2
		call_deferred("add_child", icicle)
		return
		
func create_hit_effect(body: Node2D):
	var body_size: Vector2
	if body.hitbox_iframe.shape is RectangleShape2D:
		body_size = body.hitbox_iframe.shape.size
	elif body.hitbox_iframe.shape is CircleShape2D:
		body_size = Vector2(body.hitbox_iframe.shape.radius*2, body.hitbox_iframe.shape.radius*2)
	var coordinatesX: Array[float] = [hitbox.global_position.x-hitbox.shape.size.x/2, hitbox.global_position.x+hitbox.shape.size.x/2, body.hitbox_iframe.global_position.x+body_size.x/2, body.hitbox_iframe.global_position.x-body_size.x/2]
	var coordinatesY: Array[float] = [hitbox.global_position.y-hitbox.shape.size.y/2, hitbox.global_position.y+hitbox.shape.size.y/2, body.hitbox_iframe.global_position.y+body_size.y/2, body.hitbox_iframe.global_position.y-body_size.y/2]
	coordinatesX.sort()
	coordinatesY.sort()
	var effect_x = (coordinatesX[1]+coordinatesX[2])/2
	var effect_y = (coordinatesY[1]+coordinatesY[2])/2
	var hit_effect = hit_collision_scene.instantiate()
	hit_effect.position = Vector2(effect_x, effect_y)
	hit_effect.z_index = 15
	MetSys.get_current_room_instance().add_child(hit_effect)
	
func create_effects(body: Node2D):
	sound.play_sound_effect_from_library("hit_sfx")
	create_hit_effect(body)

func update_direction():
	if get_parent().facing_position == 1:
		sprite.flip_h = false
		position.x = 38
	else:
		sprite.flip_h = true
		position.x = -38
