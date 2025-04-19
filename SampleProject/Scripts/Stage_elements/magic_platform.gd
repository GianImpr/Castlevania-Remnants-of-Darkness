extends StaticBody2D
@export var eventID: int
@export var particles: CPUParticles2D
@export var collision_box: CollisionShape2D
@export var animation: AnimationPlayer

func _ready():
	activated(Global.player.stats.event_flags[eventID])
	
func activated(trigger: bool):
	collision_box.disabled = not trigger
	particles.emitting = trigger
	visible = trigger
