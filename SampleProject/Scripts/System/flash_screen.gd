extends TextureRect
class_name FlashScreen
@export var animation: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.flash_screen = self
	
func deathFlash() -> void:
	animation.play("death_flash")

func waterDeathFlash() -> void:
	animation.play("water_death_flash")
