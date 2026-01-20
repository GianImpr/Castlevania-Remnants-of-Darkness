extends DisjointedPlayerHitbox
class_name AguniLaurelHitbox
static var hitbox_activated: bool = true
static var enemies_hit: Array[Node2D]
@export_range(0, 1, 0.1, "suffix:s") var iframes_duration: float
@export var effect: GPUParticles2D
@export var animation: AnimationPlayer
const RED_ORB_MULTIPLIER: float = 3
const RED_ORB_ANIMATION_SPEED_MULTIPLIER: float = 0.33

func _ready() -> void:
	if Global.player.stats.findItem(Skill.Skills.RED_ORB, Global.player.stats.skill_inventory):
		animation.speed_scale = RED_ORB_ANIMATION_SPEED_MULTIPLIER
		effect.amount *= RED_ORB_MULTIPLIER
		effect.lifetime *= RED_ORB_MULTIPLIER
		extra_base_damage *= RED_ORB_MULTIPLIER

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	
func _on_hit(body: Node2D) -> void:
	if body is IceBlock:
		body.evaporate()
		
	if not hitbox_activated and body in enemies_hit:
		return
		
	hitbox_activated = false
	enemies_hit.append(body)
	get_tree().create_timer(iframes_duration).timeout.connect(enableHitbox.bind(body))
	_on_body_entered(body, false)

static func enableHitbox(body) -> void:
	if body != null:
		enemies_hit.erase(body)
	hitbox_activated = true
