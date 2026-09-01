# The window that contains a bigger map overview than minimap. Toggled with M.
extends Panel
class_name MapView

# The size of the window in cells.
var SIZE: Vector2i

# The position where the player started (for the vector feature).
var starting_coords: Vector2i
# The offset for drawing the cells. Allows map panning.
var offset: Vector2i
# The player location node from MetSys.add_player_location()
var player_location: Node2D
# The vector feature, toggled with D. It displays an arrow from player's starting point to the current position.
# It's purely to show custom drawing on the map.
var show_delta: bool
static var layer: int = -10000
@export var sound: PolyphonicMenuAudio
@export var stage_name: Label
@export var stage_percent: Label
@export var previous_stage_name: RichTextLabelWithButtons
@export var next_stage_name: RichTextLabelWithButtons

const STAGE_NAMES: Array[String] = [
	"ABANDONED_MONASTERY",
	"FAGARAS_FOREST",
	"FAGARAS_FOREST",
	"MOONLIT_WATERWAY"
]

const STAGE_OFFSETS: Array[Vector2] = [
	Vector2(0, 3),
	Vector2(24, -2),
	Vector2(46, -2),
	Vector2(59, -4)
]

func _ready() -> void:
	# Cellular size is total size divided by cell size.
	SIZE = size / MetSys.CELL_SIZE
	# Connect some signals.
	MetSys.cell_changed.connect(queue_redraw.unbind(1))
	MetSys.cell_changed.connect(update_offset.unbind(1)) # When player moves to another cell, move the map.
	MetSys.map_updated.connect(queue_redraw)
	# Create player location. We need a reference to update its offset.
	player_location = MetSys.add_player_location(self)

func _draw() -> void:
	SIZE = size / MetSys.CELL_SIZE
	SIZE = Vector2(SIZE) / scale

	if layer == -10000:
		layer = MetSys.current_layer
	
	if not worldMapLayer():
		drawMap(layer)
	else:
		for i in range(0, STAGE_OFFSETS.size()):
			drawMap(i, STAGE_OFFSETS[i])

func drawMap(map_layer: int, stage_offset: Vector2 = Vector2.ZERO) -> void:
	for x in SIZE.x:
		for y in SIZE.y:
			# Draw cells. Note how offset is used.
			MetSys.draw_cell(self, Vector2i(x, y), Vector3i(x - offset.x - stage_offset.x, y - offset.y - stage_offset.y, map_layer))
	# Draw shared borders and custom elements.
	if MetSys.settings.theme.use_shared_borders:
		MetSys.draw_shared_borders()
	MetSys.draw_custom_elements(self, Rect2i(-offset.x-stage_offset.x, -offset.y-stage_offset.y, SIZE.x, SIZE.y))
	# Get the current player coordinates.
	var coords := MetSys.get_current_flat_coords()
	# If the delta vector (D) is enabled and player isn't on the starting position...
	if show_delta and coords != starting_coords:
		var start_pos := MetSys.get_cell_position(starting_coords + offset)
		var current_pos := MetSys.get_cell_position(coords + offset)
		# draw the vector...
		draw_line(start_pos, current_pos, Color.WHITE, 2)
		
		const arrow_size = 4
		# and arrow. This code shows how to draw custom stuff on the map outside the MetSys functions.
		draw_set_transform(current_pos, start_pos.angle_to_point(current_pos), Vector2.ONE)
		draw_primitive([Vector2(-arrow_size, -arrow_size), Vector2(arrow_size, 0), Vector2(-arrow_size, arrow_size)], [Color.WHITE], [])


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("map") and Global.player.stats.Stats["HP"] > 0:
		if not get_parent().visible and Global.screen == Global.ScreenType.NONE:
			layer = MetSys.current_layer
			Global.screen = Global.ScreenType.MAP
			scale = Vector2.ONE
			pivot_offset = size / 2
			sound.play_sound_effect_from_library("map")
			get_parent().visible = true
			stage_name.text = tr(STAGE_NAMES[layer] + "_TITLE")
			updateStageLabels()
			update_offset()
			$"../../Minimap".visible = false
			get_tree().paused = true
			var tween = get_tree().create_tween()
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.tween_property(Global.fade_screen, "modulate", Color(1, 1, 1, 1), 0.1)
			await tween.finished
			tween = get_tree().create_tween()
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.tween_property(get_parent(), "modulate", Color(1, 1, 1, 1), 0.1)
			await tween.finished
			return
		if get_parent().visible and Global.screen == Global.ScreenType.MAP:
			layer = MetSys.current_layer
			sound.play_sound_effect_from_library("map")
			var tween = get_tree().create_tween()
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.tween_property(get_parent(), "modulate", Color(0, 0, 0, 1), 0.1)
			await tween.finished
			get_parent().modulate = Color(0,0,0,0)
			tween = get_tree().create_tween()
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.tween_property(Global.fade_screen, "modulate", Color(1, 1, 1, 0), 0.1)
			await tween.finished
			if Global.screen == Global.ScreenType.MAP:
				get_tree().paused = false
			get_parent().visible = false
			$"../../Minimap".visible = true
			Global.screen = Global.ScreenType.NONE
			update_offset()
			
	if Input.is_action_just_pressed("backdash") and Global.screen == Global.ScreenType.MAP and not worldMapLayer():
		layer = posmod(layer-1, 4)
		while MetSys.get_explored_ratio(layer) == 0:
			layer = posmod(layer-1, 4)
		updateMapView()
	elif Input.is_action_just_pressed("guard") and Global.screen == Global.ScreenType.MAP and not worldMapLayer():
		layer = posmod(layer+1, 4)
		while MetSys.get_explored_ratio(layer) == 0:
			layer = posmod(layer+1, 4)
		updateMapView()
	elif Input.is_action_just_pressed("attack") and Global.screen == Global.ScreenType.MAP:
		if layer == 0:
			layer = -9999
		elif layer == -9999:
			layer = 0
		else:
			layer = -layer
		updateMapView()

func updateMapView():
	const FADE_DURATION: float = 0.1
	var fade_tween: Tween = get_tree().create_tween()
	fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_tween.tween_property(get_parent(), "modulate", Color.BLACK, FADE_DURATION)
	await fade_tween.finished
	sound.play_sound_effect_from_library("change")
	if not worldMapLayer():
		scale = Vector2.ONE
		pivot_offset = size / 2
	else:
		scale = Vector2(0.33,0.33)
		pivot_offset = Vector2(size.x/9, size.y/2)

	size = Vector2(825, 440) / scale
	queue_redraw()
	update_offset()
	updateStageLabels()
	if not worldMapLayer():
		stage_name.text = tr(STAGE_NAMES[layer] + "_TITLE")
	else:
		stage_name.text = "World Map"
	stage_percent.update()
	fade_tween = get_tree().create_tween()
	fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_tween.tween_property(get_parent(), "modulate", Color.WHITE, FADE_DURATION)
	
func updateStageLabels():
	if worldMapLayer():
		previous_stage_name.visible = false
		next_stage_name.visible = false
		return
	
	var next_layer: int = posmod(layer+1, 4)
	while MetSys.get_explored_ratio(next_layer) == 0:
		next_layer = posmod(next_layer+1, 4)
		
	var prev_layer: int = posmod(layer-1, 4)
	while MetSys.get_explored_ratio(prev_layer) == 0:
		prev_layer = posmod(prev_layer-1, 4)
		
	previous_stage_name.visible = prev_layer != layer
	next_stage_name.visible = prev_layer != layer
	previous_stage_name.new_text = " [[L1]] " + tr(STAGE_NAMES[prev_layer] + "_TITLE")
	next_stage_name.new_text = tr(STAGE_NAMES[next_layer] + "_TITLE") + " [[R1]]"


func _input(event: InputEvent) -> void:
	pass
	if event is InputEventAction:
		if event.pressed:
			pass
			# Toggle visibility when pressing M.
			#elif event.keycode == KEY_D:
				# D toggles position tracking (delta vector).
				#show_delta = not show_delta
				#queue_redraw()

func update_offset():
	# Update the map offset based on the current position.
	# Normally the offset is interactive and the player is able to move freely around the map.
	# But in this demo, the map can overlay the game and thus is updated in real time.
	offset = Vector2(2,13)
	#offset = -MetSys.get_current_flat_coords() + SIZE / 2
	player_location.offset = Vector2(offset) * MetSys.CELL_SIZE
	if worldMapLayer():
		player_location.offset += STAGE_OFFSETS[MetSys.current_layer] * MetSys.CELL_SIZE
	player_location.visible = layer == MetSys.current_layer or worldMapLayer()

func reset_starting_coords():
	# Starting position for the delta vector.
	var coords := MetSys.get_current_flat_coords()
	starting_coords = Vector2i(coords.x, coords.y)
	queue_redraw()

func worldMapLayer() -> bool:
	return layer < 0
