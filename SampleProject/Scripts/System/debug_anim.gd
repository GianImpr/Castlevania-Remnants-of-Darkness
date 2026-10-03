extends Sprite2D

func _ready():
	visibility_changed.connect(_on_anim_started)

func _on_anim_started():
	if visible:
		print("idle started, backtrace:")
		for line in Engine.capture_script_backtraces(true):
			print("  ", line)   
