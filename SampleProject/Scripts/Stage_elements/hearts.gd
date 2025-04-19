extends RigidBody2D
class_name Heart
@export var innocent_heart_texture: CompressedTexture2D
@export var SPEED: float
@export var sprite: Sprite2D
@export var type: Type:
	set(value):
		if value == Type.INNOCENT:
			sprite.texture = innocent_heart_texture
			type = value
const INNOCENT_DEVIL_HEAL_SMALL: int = 5

@export var animation: AnimationPlayer
enum Type {
	SOUL,
	INNOCENT
}

func _ready():
	linear_velocity.x = SPEED
	determineType()

	
func _physics_process(delta: float) -> void:
	linear_velocity.x = SPEED * sin(Time.get_ticks_msec()/300)
	if is_on_floor():
		linear_velocity.x = 0
		if not animation.is_playing():
			animation.play("idle")
			
func is_on_floor():
	return linear_velocity.y < 10


func _on_area_2d_body_entered(body: Node2D) -> void:
	match type:
		Type.SOUL:
			Global.player.stats.Stats["MP"] = min(Global.player.stats.Stats["MP"]+Global.player.stats.Stats["MMP"]/20, Global.player.stats.Stats["MMP"])
		Type.INNOCENT:
			Global.player.heal_innocent(INNOCENT_DEVIL_HEAL_SMALL)
	animation.play("picked")

# Determines whether the heart should be for MP or Innocent Devils
func determineType() -> void:
	var MP_ratio = 1 - float(Global.player.stats.Stats["MP"])/Global.player.stats.Stats["MMP"]
	var Heart_ratio = -1
	const LOWEST_CHANCE: int = 1
	const HIGHEST_CHANCE: int = 100
	if Global.player.innocent_devil != null:
		Heart_ratio = 1 - float(Global.player.innocent_devil.stats.Stats["Hearts"]) / Global.player.innocent_devil.stats.Stats["MHearts"]
	if randi_range(LOWEST_CHANCE, HIGHEST_CHANCE) * MP_ratio > randi_range(LOWEST_CHANCE, HIGHEST_CHANCE) * Heart_ratio:
		type = Type.SOUL
	else:
		type = Type.INNOCENT
