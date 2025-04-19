extends Node
class_name HardModeOnly

func _ready():
	if Global.game.difficulty != Global.game.Difficulty.CRAZY:
		queue_free()
