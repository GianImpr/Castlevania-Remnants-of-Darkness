extends Enemy
@export var vision: Area2D
@export var mince: Area2D
@export var fire: Area2D
@export var swing: Area2D
@export var sword_linger: Area2D
var activated_AI: bool = false
var facing_position: int

func _ready() -> void:
	super()
	facing_position = 1
	if Global.game.disable_lights:
		get_child(4).amount /= 10
		get_child(18).amount /= 10

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity()*2 * delta
		
	remove_glow_if_glowing()
	move_and_slide()


func _on_detection_body_entered(body: Node2D) -> void:
	hit_target(1, body)
	

func _on_swing_body_entered(body: Node2D) -> void:
	hit_target(2.5, body, swing, 8)
	

func _on_fire_body_entered(body: Node2D) -> void:
	hit_target(3, body, fire, stats.ATK, false, Global.Attribute.FIRE)


func _on_mince_body_entered(body: Node2D) -> void:
	hit_target(1.5, body, mince, 0, false, Global.Attribute.HIT, 0.5)
	
func _on_sword_linger_body_entered(body: Node2D) -> void:
	hit_target(1.2, body, sword_linger)
