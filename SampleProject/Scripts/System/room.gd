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
@export var save_room_id: int
@export var disable_pixel_snap: bool = false

func _ready() -> void:
	if save_room_id > 0:
		Global.player.stats.save_flags[save_room_id-1] = true

	Global.camera.drag_vertical_enabled = not center_camera
	
	if apply_limits:
		if camera_limit_left == 0 and camera_limit_right == 0:
			camera_limit_left = 0
			camera_limit_right = 864
		
		if camera_limit_bottom == 0 and camera_limit_top == 0:
			camera_limit_top = 0
			camera_limit_bottom = 480
			
		Global.camera.limit_left = camera_limit_left
		Global.camera.limit_right = camera_limit_right
		Global.camera.limit_top = camera_limit_top
		Global.camera.limit_bottom = camera_limit_bottom
		
	if (Global.music_player.stream.resource_name != stage_music or Global.music_player.volume_db == -80 or not Global.music_player.playing) and change_music:
		Global.music_player.stream.resource_name = stage_music
		Global.music_player.volume_db = -15
		Global.music_player.stop()
		Global.music_player.play_sound_effect_from_library(stage_music)
		
	# This is garbage but what can you do. Literally just here for the elevator not jittering like crazy.
	if disable_pixel_snap:
		match Global.settings_node.settings["framerate"]:
			0:
				Engine.max_fps = 60
			1:
				Engine.max_fps = 120
			2:
				Engine.max_fps = 0
	else:
		match Global.settings_node.settings["framerate"]:
			0:
				Engine.max_fps = 60
			1:
				Engine.max_fps = 144
			2:
				Engine.max_fps = 0
	RenderingServer.viewport_set_snap_2d_transforms_to_pixel(Global.get_viewport().get_viewport_rid(), not disable_pixel_snap)
