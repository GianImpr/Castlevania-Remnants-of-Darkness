extends CanvasLayer

@export var default_button: InventoryButton

func _ready() -> void:
	default_button.grab_focus()
