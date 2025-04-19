extends Node2D
class_name Room
@export var stage_music: String
@export var change_music: bool
@export var center_camera: bool
@export var apply_limits: bool

@export var camera_limit_left: int
@export var camera_limit_right: int
@export var camera_limit_top: int
@export var camera_limit_bottom: int
@export var save_room: bool

func _ready() -> void:
	Global.camera.drag_vertical_enabled = not center_camera
	
	if apply_limits:
		Global.camera.limit_left = camera_limit_left
		Global.camera.limit_right = camera_limit_right
		Global.camera.limit_top = camera_limit_top
		Global.camera.limit_bottom = camera_limit_bottom
	
	if (Global.music_player.stream.resource_name != stage_music or Global.music_player.volume_db == -80 or not Global.music_player.playing) and change_music:
		Global.music_player.stream.resource_name = stage_music
		Global.music_player.volume_db = -15
		Global.music_player.stop()
		Global.music_player.play_sound_effect_from_library(stage_music)
