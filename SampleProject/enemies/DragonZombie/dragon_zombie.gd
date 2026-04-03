extends Enemy
class_name DragonZombie

var facing_position: int
@export var is_moving: bool = true
@export var contact_damage_multiplier: float = 1

@export var bite_area: Area2D
@export var breath_area: Area2D
@export var laser_area: Area2D
@export var tail_sprite: Sprite2D

const BITE_DAMAGE_MULTIPLIER: float = 2.7
const BITE_CHIP_DAMAGE: int = 15
const BREATH_DAMAGE_MULTIPLIER: float = 0.5
const BREATH_CHIP_DAMAGE: int = 0
const LASER_DAMAGE_MULTIPLIER: float = 3
const LASER_CHIP_DAMAGE: int = 25

const MINIMUM_DISTANCE: float = 450

func _ready() -> void:
	super()
	facing_position = -1
	iframe_timer.timeout.connect(_on_iframe_timer_timeout)
	hitbox_iframe.area_entered.connect(_on_area_2d_area_entered)
	breath_area.area_entered.connect(_on_area_2d_breath_entered)
	bite_area.area_entered.connect(_on_area_2d_bite_entered)
	laser_area.area_entered.connect(_on_area_2d_laser_entered)
	
func _process(delta: float) -> void:
	tail_sprite.self_modulate = sprite.self_modulate

func _physics_process(delta: float) -> void:
	if not is_on_floor() and motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		velocity += get_gravity()*2 * delta
		
	remove_glow_if_glowing()
	move_and_slide()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(contact_damage_multiplier, body, hitbox_iframe, 0, false, Global.Attribute.HIT, 1, true)

func _on_area_2d_bite_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(BITE_DAMAGE_MULTIPLIER, body, bite_area, BITE_CHIP_DAMAGE, false, Global.Attribute.HIT, 1, true)

func _on_area_2d_breath_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(BREATH_DAMAGE_MULTIPLIER, body, breath_area, BREATH_CHIP_DAMAGE, false, Global.Attribute.POISON)

func _on_area_2d_laser_entered(area: Area2D) -> void:
	var body = area.get_parent()
	hit_target(LASER_DAMAGE_MULTIPLIER, body, laser_area, LASER_CHIP_DAMAGE, true, Global.Attribute.FIRE, 1, true)

func _on_iframe_timer_timeout() -> void:
	if stats.HP > 0:
		hitbox_iframe.get_child(0).set_deferred("disabled", false)
