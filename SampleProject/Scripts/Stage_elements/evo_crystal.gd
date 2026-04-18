extends RigidBody2D
class_name EvoCrystal
@export var power: int
@export var sprite: Sprite2D
@export var animation: AnimationPlayer
@export var sound: PolyphonicAudio
@export var area: Area2D
@export var evo_crystals: Array[CompressedTexture2D]
var can_track_innocent_devil: bool = false
var type: Type
const SPEED: float = 400
signal picked

enum Type {
	RED,
	BLUE,
	GREEN,
	YELLOW,
	WHITE
}

func _ready():
	type = Global.player.stats.evoCrystalType()
	sprite.texture = evo_crystals[type]
	
func _physics_process(delta: float) -> void:
	if can_track_innocent_devil:
		if Global.player.innocent_devil and Global.player.innocent_devil.is_alive:
			flyTowardsInnocentDevil(Global.player.innocent_devil)
			position = position + linear_velocity * delta
		else:
			dissolve()

func _on_area_2d_area_entered(area_body: Area2D) -> void:
	if not Global.player.innocent_devil or not Global.player.innocent_devil.is_alive:
		return
	
	if area_body.get_parent() is HectorPlayer:
		animation.play("collect")
		sound.play_sound_effect_from_library("evo")
		gravity_scale = 0
		linear_velocity = Vector2.ZERO
		picked.emit()
		area.set_collision_mask_value(2, false)
		area.set_collision_mask_value(12, false)
		area.set_collision_mask_value(20, false)
		set_collision_mask_value(13, false)
		set_collision_mask_value(1, false)
		await animation.animation_finished
		area.set_collision_mask_value(15, true)
		can_track_innocent_devil = true
	else:
		set_collision_mask_value(15, false)
		if not can_track_innocent_devil:
			sound.play_sound_effect_from_library("evo")
		dissolve()
		Global.player.innocent_devil.shine(type)

func flyTowardsInnocentDevil(devil: InnocentDevil) -> void:
	var speed_angle: float = position.angle_to_point(devil.getHurtboxCenter())
	sprite.rotation = speed_angle+PI/2
	linear_velocity = Vector2(SPEED*cos(speed_angle), SPEED*sin(speed_angle))

func dissolve() -> void:
	const DISSOLVE_DURATION: float = 0.2
	var dissolve_tween: Tween = get_tree().create_tween()
	Global.player.innocent_devil.stats.evo_crystals[type] = min(Global.player.innocent_devil.stats.evo_crystals[type]+power, 999)
	dissolve_tween.tween_property(self, "global_scale", Vector2.ZERO, DISSOLVE_DURATION)
	await dissolve_tween.finished
	queue_free()
