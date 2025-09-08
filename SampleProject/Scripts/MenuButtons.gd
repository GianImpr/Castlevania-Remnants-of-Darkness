extends Button
class_name InventoryButton
@export var state_machine: MenuStateMachine
var desired_state: MenuState

func _physics_process(delta: float) -> void:
	if state_machine:
		if not state_machine.current_state == desired_state:
			release_focus()

func fitTextInBox(size_multiplier: float = 1) -> void:
	if get_rect().size.x > custom_minimum_size.x:
		add_theme_font_size_override("font_size", get_theme_font_size("font_size")/get_rect().size.x*custom_minimum_size.x*size_multiplier)
