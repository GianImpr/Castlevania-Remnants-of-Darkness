extends StaticBody2D
class_name UkobackFireball
@export var stats: Projectile
@export var area: Area2D
@export var animation: AnimationPlayer
static var on_cooldown: bool = false
const iframes_duration: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.area_entered.connect(_on_area_2d_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area_node: Area2D) -> void:
	var body = area_node.get_parent()
	if not body.is_hurt and not on_cooldown:
		stats.apply_damage(body, stats.calculate_damage(body))
		on_cooldown = true
		if stats.destroy_on_contact:
			destroy()
		get_tree().create_timer(iframes_duration).timeout.connect(func(): on_cooldown = false)
	
func destroy():
	animation.play("destroy")
