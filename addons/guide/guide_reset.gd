extends Node


var _inputs_to_reset:Array[GUIDEInput] = []

func _enter_tree() -> void:
	# this should run at the end of the frame, so we put in a low priority (= high number)
	process_priority = 10000000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for input:GUIDEInput in _inputs_to_reset:
		input._reset()
