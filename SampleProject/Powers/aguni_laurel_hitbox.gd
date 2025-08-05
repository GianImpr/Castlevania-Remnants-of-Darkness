extends DisjointedPlayerHitbox
class_name AguniLaurelHitbox
static var hitbox_activated: bool = true
static var hit_enemies: Array[Node2D]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	
func _on_hit(body: Node2D) -> void:
	if not hitbox_activated and body in hit_enemies:
		return
		
	hitbox_activated = false
	hit_enemies.append(body)
	get_tree().create_timer(iframes_duration).timeout.connect(enableHitbox)
	_on_body_entered(body, false)

static func enableHitbox() -> void:
	hit_enemies.clear()
	hitbox_activated = true
