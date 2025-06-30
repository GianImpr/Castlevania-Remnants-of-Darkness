extends Control


@onready var _vp_container := %SubViewportContainer
@onready var _vp := %SubViewport
@onready var _level_parent := %LevelParent


func _ready() -> void:
	_ensure_save_folder_exists()
	_process_levels()


func _ensure_save_folder_exists() -> void:
	var full_save_folder := LevelshotProjectSettings.get_img_save_folder()
	var d := DirAccess.open(full_save_folder)
	if d:
		return
	
	if OK != DirAccess.make_dir_recursive_absolute(full_save_folder):
		printerr("LevelshotCapture: could not create save folder %s" % full_save_folder)
		assert(false)


func _process_levels() -> void:
	print("LevelshotCapture: beginning captures")
	var capture_data := LevelshotCaptureData.load()
	if !capture_data:
		printerr("LevelshotCapture: no capture data")
		return
	var level_shot_data := LevelshotData.load()
	if !level_shot_data:
		printerr("LevelshotCapture: no level shot data")
		return
	
	var default_level_data := level_shot_data.get_level_shot_level_data("")

	for level_scene_path in capture_data.level_scene_paths:
		var level_data := level_shot_data.get_level_shot_level_data(level_scene_path)
		if !level_data:
			printerr("LevelshotCapture: no level data for scene '%s'" % level_scene_path)
			continue
		await _process_level(level_scene_path, level_data if !level_data.mirror_default else default_level_data)
	print("LevelshotCapture: captures complete")
	get_tree().quit()


func _process_level(level_scene_path:String, data:LevelshotLevelData) -> void:
	print("LevelshotCapture: processing level %s" % level_scene_path)
	
	# unpause from any previous capture - let level run a bit if desired(see pause_before_capture_time)
	get_tree().paused = false

	var level_scene := load(level_scene_path)
	
	var loaded_level:Node = level_scene.instantiate()
	
	await get_tree().process_frame
	
	get_tree().root.add_child(loaded_level)
	get_tree().current_scene = loaded_level
	
	await get_tree().process_frame
	
	var extents := _get_level_extents(data, loaded_level)

	await get_tree().process_frame
	
	await _do_prepare(loaded_level, data)
	
	if(data.pause_before_capture_time > 0):
		await get_tree().create_timer(data.pause_before_capture_time).timeout
	
	# now pause to stop game level code from running
	get_tree().paused = true

	# and now that code is paused move level node to be under the capture viewport
	get_tree().root.remove_child.call_deferred(loaded_level)
	_level_parent.add_child.call_deferred(loaded_level)

	await get_tree().process_frame
	
	await _capture_level_extents(level_scene_path, data, extents)
	
	loaded_level.queue_free()


func _do_prepare(loaded_level:Node, data:LevelshotLevelData) -> void:
	if !data.levelshot_capture_plugin: return
	var levelshot_prepare := load(data.levelshot_capture_plugin) as Script
	if !levelshot_prepare:
		printerr("LevelshotCapture: Levelshot Capture Plugin is invalid : %s" % data.levelshot_capture_plugin)
		return
	if levelshot_prepare.get_base_script() != LevelshotCapturePlugin:
		printerr("LevelshotCapture: Levelshot Capture Plugin script not derrived from LevelshotCapturePlugin : %s" % data.levelshot_capture_plugin)
		return
	var plugin:LevelshotCapturePlugin = levelshot_prepare.new()
	@warning_ignore("redundant_await")
	await plugin.prepare(loaded_level)


func _capture_level_extents(level_scene_path:String, level:LevelshotLevelData, level_extents: Array[Rect2]) -> void:
	# any camera in the level was freed during extent calculations - so we can control the camera
	var camera := Camera2D.new()
	_vp.add_child(camera)
	camera.make_current()

	for i in level_extents.size():
		var level_extent: Rect2 = level_extents[i]
		if Vector2.ZERO.is_equal_approx(level_extent.size):
			printerr("LevelshotCapture: could not determine level boundary for level %s" % level_scene_path)
			camera.queue_free()
			await get_tree().process_frame
			return

		# size viewport/viewportcontainer - make fit into max size but keep level rect aspect ratio
		
		var viewport_size := Vector2.ZERO
		
		if level.image_size_option == LevelshotLevelData.ImageSizeOptions.SCALE or level.image_size_option == LevelshotLevelData.ImageSizeOptions.SCALEWITHMAXSIZE:
			var f := 1.0 / float(level.scale)
			viewport_size = level_extent.size * f
		if level.image_size_option == LevelshotLevelData.ImageSizeOptions.MAXSIZE or (level.image_size_option == LevelshotLevelData.ImageSizeOptions.SCALEWITHMAXSIZE and _is_size_greater(viewport_size, level.size)):
			var v := level.size / level_extent.size
			var f := minf(v.x, v.y)
			viewport_size = level_extent.size * f
		if viewport_size == Vector2.ZERO:
			printerr("LevelshotCapture: invalid image size option value for level %s: option value is %s" % [level_scene_path, level.image_size_option])
			return
		
		if viewport_size.x > Image.MAX_WIDTH or viewport_size.y > Image.MAX_HEIGHT:
			viewport_size = Vector2(Image.MAX_WIDTH, Image.MAX_HEIGHT)
			push_warning("LevelshotCapture: resulting image size is > max.  Limiting image size to %s." % viewport_size)
		
		_vp_container.size = viewport_size
		_vp.size = viewport_size

		# set these a second time - fixes issue where the first setting doesn't take
		# this happens when using scale size option on the first image generated
		await get_tree().process_frame
		_vp_container.size = viewport_size
		_vp.size = viewport_size
		await get_tree().process_frame
		
		# center camera in level
		camera.global_position = level_extent.position + level_extent.size / 2.0
		
		# zoom camera out so entire level in view
		var zoom_xy:Vector2 = _vp_container.size / level_extent.size
		var zoom := maxf(zoom_xy.x, zoom_xy.y)
		camera.zoom = Vector2(zoom, zoom)
		
		# give camera time to adjust
		await get_tree().create_timer(.1).timeout
		
		var suffix := "" if level_extents.size() == 1 else "_%d" % (i+1)
		_save_level_image(level_scene_path, suffix)
	
	# clean up
	camera.queue_free()


func _get_level_extents(level:LevelshotLevelData, loaded_level:Node) -> Array[Rect2]:
	var level_extents:Array[Rect2] = []
	if level.level_boundary_option == LevelshotLevelData.LevelBoundaryOptions.LEVELSHOTREFRECT or level.level_boundary_option == LevelshotLevelData.LevelBoundaryOptions.BOTH:
		level_extents = LevelshotLevelExtentFromRefRect.new().get_level_extents(loaded_level, level.include_canvas_layers, level.get_excluded_node_groups_array())
	if !level_extents or level.level_boundary_option == LevelshotLevelData.LevelBoundaryOptions.BOTH:
		level_extents.append_array(LevelshotLevelExtentCalculator.new().get_level_extents(loaded_level, level.include_canvas_layers, level.get_excluded_node_groups_array()))
	
	return level_extents


func _is_size_greater(a: Vector2, b: Vector2) -> bool:
	return a.x > b.x or a.y > b.y


func _save_level_image(level_scene_path: String, suffix: String) -> void:
	var texture :Texture2D = _vp.get_texture()
	var image: Image = texture.get_image()
	var base_file_name := level_scene_path.get_file().replace(".tscn", "").replace(".scn", "")
	var save_folder := LevelshotProjectSettings.get_img_save_folder()
	var image_file_path := "%s/%s%s.png" % [save_folder, base_file_name, suffix]
	var result := image.save_png(image_file_path)
	if result != OK:
		printerr("Unable to save level image to %s (error code %d)" % [image_file_path, result])
