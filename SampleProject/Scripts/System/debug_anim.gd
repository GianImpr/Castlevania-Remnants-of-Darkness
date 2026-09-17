extends AnimationPlayer

func _ready():
	animation_started.connect(_on_anim_started)

func _on_anim_started(anim_name: StringName):
	if anim_name == &"idle":
		print("idle started, backtrace:")
		for line in Engine.capture_script_backtraces(true):
			print("  ", line)   
