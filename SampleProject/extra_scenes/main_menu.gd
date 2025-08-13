extends Control
@export var loading_screen: Control
@export var name_entry_screen: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.load_data:
		loading_screen.process_mode = Node.PROCESS_MODE_ALWAYS
		name_entry_screen.process_mode = Node.PROCESS_MODE_DISABLED
		name_entry_screen.visible = false
	else:
		loading_screen.process_mode = Node.PROCESS_MODE_DISABLED
		name_entry_screen.process_mode = Node.PROCESS_MODE_ALWAYS
		name_entry_screen.visible = true
