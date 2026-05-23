extends Area2D
class_name CameraEditor
@export var apply_limits: bool = false
@export var camera_limit_left: int = 0
@export var camera_limit_right: int = 864
@export var camera_limit_top: int = 0
@export var camera_limit_bottom: int = 480
@export var apply_position_offset: bool = false
@export var position_offset: Vector2

func _ready() -> void:
	body_entered.connect(applyCameraSettings)
	body_exited.connect(resetCameraSettings)
	
func applyCameraSettings(body: Node2D) -> void:
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
	
	if apply_position_offset:
		Global.camera.dragCamera(position_offset)
	
func resetCameraSettings(body: Node2D) -> void:
	if apply_limits:
		if MetSys.get_current_room_instance():
			MetSys.get_current_room_instance().get_parent().applyCameraLimits()
	if apply_position_offset:
		Global.camera.dragCamera(Vector2.ZERO)
