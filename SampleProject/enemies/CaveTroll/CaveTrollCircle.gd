extends State
class_name CaveTrollMagic
@export var aura: CollisionShape2D
@export var aura_sprite: Sprite2D

func enter():
	animation.play("aura")
	
func exit():
	aura.set_deferred("disabled", true)
	aura_sprite.visible = false

func Update(delta: float):
	enemy_can_die()
	if not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass

func circleTrail() -> void:
	const DURATION: float = 0.5
	const FINAL_SCALE: Vector2 = Vector2(6, 6)
	var trail: Sprite2D = Sprite2D.new()
	var tween: Tween = get_tree().create_tween()
	tween.bind_node(trail)
	trail.texture = aura_sprite.texture
	trail.hframes = aura_sprite.hframes
	trail.vframes = aura_sprite.vframes
	trail.frame = aura_sprite.frame
	trail.scale = aura_sprite.scale
	trail.offset = aura_sprite.offset
	trail.global_position = aura_sprite.global_position
	tween.set_parallel()
	tween.tween_property(trail, "modulate", Color.TRANSPARENT, DURATION).from(Color(1,1,1,0.1))
	tween.tween_property(trail, "scale", FINAL_SCALE, DURATION)
	tween.finished.connect(trail.queue_free)
	MetSys.get_current_room_instance().add_child(trail)
