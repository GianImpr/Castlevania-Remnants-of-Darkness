extends Candle
@export var light: PointLight2D

func _ready() -> void:
	if Global.game.disable_lights:
		light.visible = false
		light.process_mode = Node.PROCESS_MODE_DISABLED
