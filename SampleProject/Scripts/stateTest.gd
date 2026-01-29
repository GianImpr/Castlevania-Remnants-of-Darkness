extends Label

@export var state_machine: Node

func _process(delta: float) -> void:
	text = state_machine.current_state.name
