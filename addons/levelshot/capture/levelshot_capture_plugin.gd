## Used during Levelshot capture process to allow for extra level preparation
## before capturing an image.  Just override the prepare(level:Node) -> void
## function.  You may use await during this function if necessary.
class_name LevelshotCapturePlugin
extends RefCounted


## Called before game level is paused during capture.  Use
## to affect any setup required for capture to be successful with your
## game level.
@warning_ignore("unused_parameter")
func prepare(level_node:Node) -> void:
	pass
