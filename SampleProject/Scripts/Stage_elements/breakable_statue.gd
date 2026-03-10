extends Node2D
class_name BreakableStatue
const MIN_HITS_TO_TAKE: int = 8
const MAX_HITS_TAKEN: int = 10
var hits_taken: int = 0
@export var animation: AnimationPlayer
@export var sprite: Sprite2D
@export var event_id: int
@export var hitbox_iframe: CollisionShape2D
@export var recovery_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.player.stats.event_flags[event_id]:
		queue_free()
	recovery_timer.timeout.connect(recoverHit)
	recovery_timer.start()

func takeHit(attributes: Array[Global.Attribute]) -> void:
	if Global.Attribute.ICE in attributes:
		hits_taken = min(MAX_HITS_TAKEN, hits_taken+1)
		_updateModulate()
		
	if Global.Attribute.FIRE in attributes and hits_taken >= MIN_HITS_TO_TAKE:
		_melt()

func _updateModulate() -> void:
	sprite.self_modulate = Color(1-float(hits_taken)/10,1-float(hits_taken)/20,1,1)

func recoverHit() -> void:
	hits_taken = max(0, hits_taken-1)
	_updateModulate()
	
func _melt() -> void:
	Global.player.stats.event_flags[event_id] = true
	animation.play("melt")
