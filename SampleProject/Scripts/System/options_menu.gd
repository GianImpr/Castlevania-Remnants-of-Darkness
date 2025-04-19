extends MenuState
class_name InvOptions

@export var buttons: VBoxContainer
@export var graphics_menu: VBoxContainer
@export var audio_menu: VBoxContainer
@export var controller_menu: VBoxContainer
@export var game_menu: VBoxContainer
@export var button_glow: StyleBoxFlat
@export var settings: Dictionary
@export var binding_buttons: GridContainer
@export var description: RichTextLabelWithButtons
var cur_button: InventoryButton
var functions: Array[Callable] = [changeWindowMode, changeResolution, changeScaling, changeVsync, changeFramerateDisplay, changeMasterVolume, changeSFXVolume, changeMusicVolume, changeVoiceVolume, changeControllerLayout, changeInputBuffer, changeDevice]
var descriptions: Array[String] = [
	"Change the window display mode. Objects may not be displayed properly on Stretch mode.",
	
	"Change window size, if in Windowed mode. Objects may not be displayed properly on 240p/720p.",
	
	"Change the way the objects are drawn. Viewport increases performance, but reduces image quality.",
	
	"Enable or disable V-Sync. Disabling it might reduce input lag, but it can introduce tearing.",
	
	"Enable or disable an FPS counter.",
	
	"Change the volume of the game.",
	
	"Change the volume of sound effects.",
	
	"Change the volume of music.",
	
	"Change the volume of voices.",
	
	"Pick which controller scheme the game should refer to when showing button icons.",
	
	"Adjust the size of input buffering. Higher values can improve input feedback.",
	
	"Press this button to remap buttons on the selected device."
]
var sub_menu_buttons: Array[InventoryButton]
var glow_timer: Timer = Timer.new()
var inner_menu: int = -1
var menus: Array[VBoxContainer]
var min_glow_intensity: float = 0.34
var glow_intensity: float = min_glow_intensity
var max_glow_intensity: float = 0.44
var increasing_glow: int = 1
const MAX_BUFFERED_FRAMES: int = 10
const FRAME_DURATION_MSEC: float = 16.67
var registering_input: bool = false
var current_action: int = 0
var in_bind_menu: bool = false
const path: String = "res://assets/sprites/HUD/Buttons/"
var button_icons: Dictionary
var joypad_binding_swaps: Array[Vector2i]
var keyboard_binding_swaps: Array[Vector2i]

const Buttons = {
	SQUARE = "Square",
	CIRCLE = "Circle",
	CROSS = "Cross",
	TRIANGLE = "Triangle",
	START = "Options",
	SELECT = "Select",
	L1 = "L1",
	L2 = "L2",
	L3 = "L3",
	R1 = "R1",
	R2 = "R2",
	R3 = "R3",
	A = "A",
	B = "B",
	X = "X",
	Y = "Y",
	LB = "LB",
	LT = "LT",
	RB = "RB",
	RT = "RT",
	L = "L",
	R = "R",
	LSTICK = "LeftStick",
	RSTICK = "RightStick",
	ZL = "ZL",
	ZR = "ZR",
	PLUS = "Plus",
	MINUS = "Minus",
	UP = "Up",
	DOWN = "Down",
	BACK = "Back",
	FORWARD = "Forward"
}

const binding_order: Array[String] = ["Back", "Forward", "Down", "Up", "Square", "Cross", "Circle", "Triangle", "L1", "R1", "Start", "Select", "L2"]
const initial_joypadbutton_order: Array = [
	JOY_BUTTON_DPAD_LEFT,
	JOY_BUTTON_DPAD_RIGHT,
	JOY_BUTTON_DPAD_DOWN,
	JOY_BUTTON_DPAD_UP,
	JOY_BUTTON_X,
	JOY_BUTTON_A,
	JOY_BUTTON_B,
	JOY_BUTTON_Y,
	JOY_BUTTON_LEFT_SHOULDER,
	JOY_BUTTON_RIGHT_SHOULDER,
	JOY_BUTTON_START,
	JOY_BUTTON_BACK,
	JOY_AXIS_TRIGGER_LEFT+20,
	#JOY_AXIS_TRIGGER_RIGHT+20
]

const initial_keyboardbutton_order: Array = [
	KEY_LEFT,
	KEY_RIGHT,
	KEY_DOWN,
	KEY_UP,
	KEY_J,
	KEY_K,
	KEY_L,
	KEY_I,
	KEY_O,
	KEY_U,
	KEY_ENTER,
	KEY_M,
	KEY_Y,
	KEY_P
]

var joypadbutton_order: Array = initial_joypadbutton_order.duplicate(true)
var keyboardbutton_order: Array = initial_keyboardbutton_order.duplicate(true)

func _ready() -> void:
	menus = [graphics_menu, audio_menu, controller_menu, game_menu]
	if sub_menu_buttons.size() == 0:
		initSubMenuButtons()
		
	Global.settings_node = self
	
func triggerSettings() -> void:
	for i in range(0, functions.size()-1):
		functions[i].bind(0,sub_menu_buttons[i]).call()
	setButtons(Global.game.controller_scheme)

func setButtons(scheme: int) -> void:
	match scheme:
		0:
			button_icons = {"Square": Buttons.SQUARE, "Circle": Buttons.CIRCLE, "Triangle": Buttons.TRIANGLE,
			"Cross": Buttons.CROSS, "L1": Buttons.L1, "L2": Buttons.L2, "L3": Buttons.L3, "R1": Buttons.R1,
			"R2": Buttons.R2, "R3": Buttons.R3, "Start": Buttons.START, "Select": Buttons.SELECT}
		1:
			button_icons = {"Square": Buttons.X, "Circle": Buttons.B, "Triangle": Buttons.Y,
			"Cross": Buttons.A, "L1": Buttons.LB, "L2": Buttons.LT, "L3": Buttons.LSTICK, "R1": Buttons.RB,
			"R2": Buttons.RT, "R3": Buttons.RSTICK, "Start": Buttons.START, "Select": Buttons.SELECT}	
		2:
			button_icons = {"Square": Buttons.Y, "Circle": Buttons.A, "Triangle": Buttons.X,
			"Cross": Buttons.B, "L1": Buttons.L, "L2": Buttons.ZL, "L3": Buttons.LSTICK, "R1": Buttons.R,
			"R2": Buttons.ZR, "R3": Buttons.RSTICK, "Start": Buttons.PLUS, "Select": Buttons.MINUS}
		3:
			button_icons = {"Square": "J", "Circle": "L", "Triangle": "I",
			"Cross": "K", "L1": "U", "L2": "Y", "L3": Buttons.LSTICK, "R1": "O",
			"R2": Buttons.ZR, "R3": Buttons.RSTICK, "Start": "Enter", "Select": "M"}
	
	if Global.game.controller_scheme != Global.game.ControllerScheme.KEYBOARD:
		button_icons.get_or_add("Up", Buttons.UP)
		button_icons.get_or_add("Down", Buttons.DOWN)
		button_icons.get_or_add("Back", Buttons.BACK)
		button_icons.get_or_add("Forward", Buttons.FORWARD)
	else:
		button_icons.get_or_add("Up", "Up")
		button_icons.get_or_add("Down", "Down")
		button_icons.get_or_add("Back", "Left")
		button_icons.get_or_add("Forward", "Right")
	joypadbutton_order = initial_joypadbutton_order.duplicate(true)
	keyboardbutton_order = initial_keyboardbutton_order.duplicate(true)
	applySwaps()
	updateIcons()
	
func applySwaps() -> void:
	if Global.game.controller_scheme != Global.game.ControllerScheme.KEYBOARD:
		for bindings in joypad_binding_swaps:
			var tmp = button_icons[binding_order[bindings.y]]
			button_icons[binding_order[bindings.y]] = button_icons[binding_order[bindings.x]]
			button_icons[binding_order[bindings.x]] = tmp
			var joypad_tmp = joypadbutton_order[bindings.y]
			joypadbutton_order[bindings.y] = joypadbutton_order[bindings.x]
			joypadbutton_order[bindings.x] = joypad_tmp
	else:
		for i in range(0, binding_order.size()):
			var key_event: InputEventKey = InputHelper.get_keyboard_input_for_action(Actions.values()[i])
			var scancode: int = key_event.keycode
			if scancode == 0:
				scancode = DisplayServer.keyboard_get_keycode_from_physical(key_event.physical_keycode)
			button_icons[binding_order[i]] = OS.get_keycode_string(scancode)
		
func updateIcons() -> void:
	var index = 0
	for button in binding_buttons.get_children():
		button.text = button.get_name()
		if settings["device"] == 0:
			button.icon = load(path + button_icons[binding_order[index]] + ".png")
		else:
			button.icon = null
			while (button.text.length()+button_icons[binding_order[index]].length() < 13):
				button.text += " "
			if (button.text.length() > 13-button_icons[binding_order[index]].length()):
				button.text = button.text.substr(0, 13-button_icons[binding_order[index]].length())
			button.text += button_icons[binding_order[index]]
		index += 1
		if index >= binding_order.size():
			return
			
func updateUIActions() -> void:
	var ui_actions: Array[String] = ["ui_left", "ui_right", "ui_down", "ui_up", "ui_accept", "ui_cancel"]
	var reference_actions: Array[String] = ["move_left", "move_right", "crouch", "up_arrow", "jump", "circle"]
	for i in range(0, ui_actions.size()):
		if Global.game.controller_scheme != Global.game.ControllerScheme.KEYBOARD:
			InputHelper.set_joypad_input_for_action(ui_actions[i], InputHelper.get_joypad_input_for_action(reference_actions[i]), false)
		else:
			InputHelper.set_keyboard_input_for_action(ui_actions[i], InputHelper.get_keyboard_input_for_action(reference_actions[i]), false)

enum panel {
	GRAPHICS,
	AUDIO,
	CONTROLLER
}

const Buses = {
	MASTER = "Master",
	SFX = "SFX",
	VOICE = "Voice",
	MUSIC = "Music"
}

const Actions = {
	LEFT = "move_left",
	RIGHT = "move_right",
	DOWN = "crouch",
	UP = "up_arrow",
	ATTACK = "attack",
	JUMP = "jump",
	SPECIAL = "circle",
	IDSKILL = "innocent_devil_move",
	BACKDASH = "backdash",
	GUARD = "guard",
	INVENTORY = "menu",
	MAP = "map",
	SWITCH = "l2"
}

func enter():
	animation.play_backwards("change")
	default_button.grab_focus()
	

func exit():
	animation.play("change")
	registering_input = false
	hideInnerMenu()
	
func _unhandled_input(event) -> void:
	if registerJoypadInput(event) or registerKeyboardInput(event):
		updateUIActions()
		setButtons(Global.game.controller_scheme)
			
			
func registerJoypadInput(event) -> bool:
	if registering_input and Global.game.controller_scheme != Global.game.ControllerScheme.KEYBOARD:
		current_action = binding_buttons.get_children().find(cur_button)
		if (event is InputEventJoypadButton or event is InputEventJoypadMotion) and event.is_pressed():
			if event is InputEventJoypadButton and event.button_index not in initial_joypadbutton_order or event is InputEventJoypadMotion and event.axis+20 not in initial_joypadbutton_order:
				return false
				
			var action = Actions.values()[current_action]
			var old_input = InputHelper.get_joypad_input_for_action(action)
			var old_bind: int = 0
			var new_bind: int = 0
			var new_input = event

			if old_input is InputEventJoypadButton:
				old_bind = joypadbutton_order.find((old_input as InputEventJoypadButton).button_index)
			elif old_input is InputEventJoypadMotion:
				old_bind = joypadbutton_order.find((old_input as InputEventJoypadMotion).axis+20) #The +20 is to differentiate axis inputs from button inputs
			InputHelper.set_joypad_input_for_action(action, event)
			
			if new_input is InputEventJoypadButton:
				new_bind = joypadbutton_order.find((new_input as InputEventJoypadButton).button_index)
			elif new_input is InputEventJoypadMotion:
				new_bind = joypadbutton_order.find((new_input as InputEventJoypadMotion).axis+20)
						
			registering_input = false
			cur_button.grab_focus()
			
			if old_bind != new_bind:
				joypad_binding_swaps.append(Vector2i(old_bind, new_bind))
			return true
	return false
	
func registerKeyboardInput(event) -> bool:
	if registering_input and Global.game.controller_scheme == Global.game.ControllerScheme.KEYBOARD:
		current_action = binding_buttons.get_children().find(cur_button)
		
		if (event is InputEventKey) and event.is_pressed():
			var action = Actions.values()[current_action]
			var old_input = InputHelper.get_keyboard_input_for_action(action)
			var old_bind: int = 0
			var new_bind: int = 0
			var new_input = event

			if old_input is InputEventKey:
				old_bind = keyboardbutton_order.find((old_input as InputEventKey).keycode)
			InputHelper.set_keyboard_input_for_action(action, event)
			
			if new_input is InputEventKey:
				new_bind = keyboardbutton_order.find((new_input as InputEventKey).keycode)
						
			registering_input = false
			cur_button.grab_focus()
			
			if old_bind != new_bind:
				keyboard_binding_swaps.append(Vector2i(old_bind, new_bind))
			return true
	return false

func Update(delta: float):
	if Input.is_action_just_pressed("ui_cancel") and inner_menu == -1:
		Transitioned.emit(self, "menu")
	elif Input.is_action_just_pressed("ui_cancel") and not in_bind_menu:
		buttons.get_child(inner_menu).grab_focus()
		hideInnerMenu()
	elif Input.is_action_just_pressed("ui_cancel") and in_bind_menu and not registering_input:
		in_bind_menu = false
		sub_menu_buttons[functions.size()-1].grab_focus()
		
	if Input.is_action_just_pressed("move_right") and inner_menu >= 0 and sub_menu_buttons.find(cur_button) < functions.size():
		functions[sub_menu_buttons.find(cur_button)].bind(1, cur_button).call()
	elif Input.is_action_just_pressed("move_left") and inner_menu >= 0 and sub_menu_buttons.find(cur_button) < functions.size():
		functions[sub_menu_buttons.find(cur_button)].bind(-1, cur_button).call()
	
func Physics_Update(delta: float):
	pass
	
func hideInnerMenu() -> void:
	graphics_menu.visible = false
	audio_menu.visible = false
	controller_menu.visible = false
	game_menu.visible = false
	inner_menu = -1
	description.new_text = ""

func initSubMenuButtons() -> void:
	glow_timer.wait_time = 10
	add_child.call_deferred(glow_timer)
	glow_timer.timeout.connect(self._on_change_glow_timeout)

	for vbox in menus:
		for i in range(0, vbox.get_child_count()):
			if vbox.get_child(i) is GridContainer:
				var grid: GridContainer = vbox.get_child(i)
				var index: int = 0
				for button in grid.get_children():
					sub_menu_buttons.append(button)
					button.desired_state = self
					button["theme_override_styles/focus"] = button_glow
					button.focus_neighbor_bottom = grid.get_child((index+2)%grid.get_child_count()).get_path()
					button.focus_neighbor_top = grid.get_child((index-2)%grid.get_child_count()).get_path()
					button.focus_neighbor_right = grid.get_child((index+1)%grid.get_child_count()).get_path()
					button.focus_neighbor_left = grid.get_child((index-1)%grid.get_child_count()).get_path()
					if index != grid.get_child_count()-1:
						button.pressed.connect(self.on_bind_button_pressed.bind(button))
					else:
						button.pressed.connect(self.on_reset_bind_button_pressed.bind(button))
					button.focus_entered.connect(self.on_sub_button_focused.bind(button))
					index += 1
				continue
					
			var hbox: HBoxContainer = vbox.get_child(i)
			var sub_menu_button: InventoryButton = hbox.get_child(0)
			sub_menu_buttons.append(sub_menu_button)
			sub_menu_button.desired_state = self
			if vbox == controller_menu:
				sub_menu_button.focus_neighbor_bottom = vbox.get_child(posmod((i+1),(vbox.get_child_count()-1))).get_child(0).get_path()
				sub_menu_button.focus_neighbor_top = vbox.get_child(posmod((i-1),(vbox.get_child_count()-1))).get_child(0).get_path()
				sub_menu_button.focus_neighbor_right = sub_menu_button.get_path()
			else:
				sub_menu_button.focus_neighbor_bottom = vbox.get_child(posmod((i+1),vbox.get_child_count())).get_child(0).get_path()
				sub_menu_button.focus_neighbor_top = vbox.get_child(posmod((i-1),vbox.get_child_count())).get_child(0).get_path()
			sub_menu_button["theme_override_styles/focus"] = button_glow
			if vbox != game_menu:
				sub_menu_button.pressed.connect(self.on_sub_button_pressed.bind(sub_menu_button))
				sub_menu_button.focus_entered.connect(self.on_sub_button_focused.bind(sub_menu_button))
			else:
				sub_menu_button.pressed.connect(self.on_game_button_pressed.bind(sub_menu_button))
				sub_menu_button.focus_entered.connect(self.on_game_button_focused.bind(sub_menu_button))


			
func _process(delta: float) -> void:
	if menu.state_machine.current_state == self:
		glow_intensity = glow_intensity + 0.1*delta*increasing_glow
		if glow_intensity >= max_glow_intensity:
			increasing_glow = -1
		elif glow_intensity < min_glow_intensity:
			increasing_glow = 1
		if glow_timer.is_stopped():
			glow_timer.start()
	elif not glow_timer.is_stopped():
		glow_timer.stop()
			
func _on_change_glow_timeout():
	if Global.game != null and Global.game.disable_lights:
		return
	for button in sub_menu_buttons:
		button_glow.bg_color = Color(glow_intensity, 0, 0)
		
func on_sub_button_pressed(which):
	if which == sub_menu_buttons[functions.size()-1]:
		in_bind_menu = true
		sub_menu_buttons[functions.size()].grab_focus()
		sound.play_sound_effect_from_library("confirm")
		return
	sound.play_sound_effect_from_library("denied")
	
func on_sub_button_focused(which):
	cur_button = which
	if sub_menu_buttons.find(cur_button) < descriptions.size():
		description.new_text = descriptions[sub_menu_buttons.find(cur_button)]
	sound.play_sound_effect_from_library("cursor")

func on_game_button_pressed(which):
	sound.play_sound_effect_from_library("confirm")
	if which.get_name() == "Quit game":
		get_tree().quit()
	else:
		Global.toTitleScreen()
	
func on_game_button_focused(which):
	cur_button = which
	if which.get_name() == "Quit game":
		description.new_text = "Closes the game.\nBe sure to save your data before closing."
	else:
		description.new_text = "Return to the title screen.\nBe sure to save your data."
	sound.play_sound_effect_from_library("cursor")


func on_bind_button_pressed(which):
	sound.play_sound_effect_from_library("confirm")
	which.release_focus()
	registering_input = true
	
func on_reset_bind_button_pressed(which):
	sound.play_sound_effect_from_library("confirm")
	InputHelper.reset_all_actions()
	joypad_binding_swaps.clear()
	joypadbutton_order = initial_joypadbutton_order.duplicate(true)
	setButtons(Global.game.controller_scheme)
	


func changeResolution(offset: int, button: InventoryButton) -> void:
	if get_tree().root.get_window().mode != Window.Mode.MODE_WINDOWED and offset != 0:
		sound.play_sound_effect_from_library("denied")
		return
	var default_viewport: Vector2i = Vector2i(864, 480)
	const resolutions: Array[float] = [0.5, 1, 1.5, 2, 3, 4]
	settings["resolution"] = posmod((settings["resolution"]+offset),resolutions.size())
	if settings["resolution"] == 0 or settings["resolution"] == 2:
		get_tree().root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	else:
		get_tree().root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
	var new_viewport = default_viewport * resolutions[settings["resolution"]]
	var setting_label: Label = button.get_parent().get_child(2)
	setting_label.text = str(new_viewport.x) + "x" + str(new_viewport.y)
	DisplayServer.window_set_size(new_viewport)
	
func changeWindowMode(offset: int, button: InventoryButton) -> void:
	const modes: Array[String] = ["Windowed", "Fullscreen", "Stretch"]
	settings["window_mode"] = posmod(settings["window_mode"]+offset,modes.size())
	var setting_label: Label = button.get_parent().get_child(2)
	setting_label.text = modes[settings["window_mode"]]
	match settings["window_mode"]:
		0:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
			get_tree().root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
		2: 
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
			get_tree().root.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL

func changeScaling(offset: int, button: InventoryButton) -> void:
	const modes: Array[String] = ["Canvas", "Viewport"]
	settings["scaling"] = posmod(settings["scaling"]+offset,modes.size())
	var setting_label: Label = button.get_parent().get_child(2)
	setting_label.text = modes[settings["scaling"]]
	if settings["scaling"] == 0:
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	else:
		get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		
func changeLight(offset: int, button: InventoryButton) -> void:
	const modes: Array[String] = ["Enabled", "Disabled"]
	settings["light"] = posmod(settings["light"]+offset,modes.size())
	var setting_label: Label = button.get_parent().get_child(2)
	setting_label.text = modes[settings["light"]]
	Global.game.disable_lights = settings["light"] == 1

func changeVsync(offset: int, button: InventoryButton) -> void:
	const modes: Array[String] = ["Enabled", "Disabled"]
	settings["vsync"] = posmod(settings["vsync"]+offset,modes.size())
	var setting_label: Label = button.get_parent().get_child(2)
	setting_label.text = modes[settings["vsync"]]
	if settings["vsync"] == 0:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
func changeFramerateDisplay(offset: int, button: InventoryButton) -> void:
	const modes: Array[String] = ["No", "Yes"]
	settings["frames"] = posmod(settings["frames"]+offset,modes.size())
	var setting_label: Label = button.get_parent().get_child(2)
	setting_label.text = modes[settings["frames"]]
	Global.fps_display.visible = settings["frames"] == 1
	
func changeMasterVolume(offset: int, button: InventoryButton) -> void:
	changeAudioServerVolume(offset, button, Buses.MASTER, "master_volume", 2)

func changeSFXVolume(offset: int, button: InventoryButton) -> void:
	changeAudioServerVolume(offset, button, Buses.SFX, "sfx_volume")
	
func changeMusicVolume(offset: int, button: InventoryButton) -> void:
	changeAudioServerVolume(offset, button, Buses.MUSIC, "music_volume")
	
func changeVoiceVolume(offset: int, button: InventoryButton) -> void:
	changeAudioServerVolume(offset, button, Buses.VOICE, "voice_volume")

func changeAudioServerVolume(offset: int, button: InventoryButton, bus: String, dict_entry: String, multiplier: float = 1) -> void:
	settings[dict_entry] = max(min(settings[dict_entry]+offset*5, 100), 0)
	var setting_label: Label = button.get_parent().get_child(2)
	setting_label.text = str(settings[dict_entry]) + "%"
	var sfx_index= AudioServer.get_bus_index(bus)
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(float(settings[dict_entry])/100*multiplier))

func changeControllerLayout(offset: int, button: InventoryButton) -> void:
	const modes: Array[String] = ["Playstation", "Xbox", "Nintendo"]
	settings["layout"] = posmod(settings["layout"]+offset,modes.size())
	var setting_label: Label = button.get_parent().get_child(2)
	setting_label.text = modes[settings["layout"]]
	match settings["layout"]:
		0:
			Global.game.controller_scheme = Global.game.ControllerScheme.PLAYSTATION
		1:
			Global.game.controller_scheme = Global.game.ControllerScheme.XBOX
		2: 
			Global.game.controller_scheme = Global.game.ControllerScheme.NINTENDO
	setButtons(Global.game.controller_scheme)

func changeInputBuffer(offset: int, button: InventoryButton) -> void:
	settings["buffer"] = posmod(settings["buffer"]+offset,MAX_BUFFERED_FRAMES)
	var setting_label: Label = button.get_parent().get_child(2)
	if settings["buffer"] > 0:
		setting_label.text = str(settings["buffer"]) + " frames"
	else:
		setting_label.text = "Disabled"
	InputBuffer.BUFFER_WINDOW = settings["buffer"]*FRAME_DURATION_MSEC

func changeDevice(offset: int, button: InventoryButton) -> void:
	settings["device"] = posmod(settings["device"]+offset,2)
	var setting_label: Label = button.get_parent().get_child(2)
	if settings["device"] == 0:
		setting_label.text = "Controller"
		match settings["layout"]:
			0:
				Global.game.controller_scheme = Global.game.ControllerScheme.PLAYSTATION
			1:
				Global.game.controller_scheme = Global.game.ControllerScheme.XBOX
			2: 
				Global.game.controller_scheme = Global.game.ControllerScheme.NINTENDO
	else:
		setting_label.text = "Keyboard"
		Global.game.controller_scheme = Global.game.ControllerScheme.KEYBOARD
	setButtons(Global.game.controller_scheme)
