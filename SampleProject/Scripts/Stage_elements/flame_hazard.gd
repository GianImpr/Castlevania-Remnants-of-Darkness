extends StaticBody2D
class_name FlameHazard
@export var event_ID: int
@export var power: int
@export var hitbox_iframe: CollisionShape2D
@export var iframe_timer: Timer
@export var animation: AnimationPlayer
@export var tutorial_hint: HintBoxTrigger

func _ready():
	if Global.player.stats.event_flags[event_ID]:
		queue_free()
		
	
func calculate_damage(body, multiplier) -> int:
	var damage
	damage = (power - body.stats.Stats["DEF"]/2)*multiplier
		
	if body.isGuarding():
		if damage < body.stats.Stats["MHP"]/10 and body.stats.Stats["Guard"] > 1:
			damage = 0
		elif damage >= body.stats.Stats["MHP"]/10 and body.stats.Stats["Guard"] > 1:
			damage *= 0.2
		elif body.stats.Stats["Guard"] == 1:
			damage *= 0.6
		body.stats.Stats["Guard"] -= 1
	return damage
	
func apply_damage(body, damage):
	body.damage_popup.popup(damage, 0)
	body.stats.Stats["HP"] = max(body.stats.Stats["HP"]-damage, 0)
	body.is_hurt = true
	hitbox_iframe.set_deferred("disabled", true)
	iframe_timer.start()


func _on_iframe_timer_timeout() -> void:
	hitbox_iframe.set_deferred("disabled", false)

func _on_hitbox_body_entered(body: Node2D) -> void:
	var multiplier = 1
	if not body.is_hurt:
		var damage = calculate_damage(body, multiplier)
		apply_damage(body, damage)

func destroy():
	Global.player.stats.event_flags[event_ID] = true
	if tutorial_hint != null:
		tutorial_hint.queue_free()
	animation.play("disappear")
