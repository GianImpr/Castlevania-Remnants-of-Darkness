extends Button
class_name InventoryButton
@export var state_machine: MenuStateMachine
var desired_state: MenuState

func _physics_process(delta: float) -> void:
	if state_machine:
		if not state_machine.current_state == desired_state:
			release_focus()
