extends GridContainer

@export var button_glow: StyleBoxFlat
var glow_timer = Timer.new()
@export var sound: PolyphonicMenuAudio
@export var menu: MenuState
@export var state_machine: MenuStateMachine
var min_glow_intensity: float = 0.34
var glow_intensity: float = min_glow_intensity
var max_glow_intensity: float = 0.44
var increasing_glow: int = 1
var children: Array[Button]

func _ready() -> void:
	glow_timer.wait_time = 0.1;
	get_parent().add_child.call_deferred(glow_timer)
	glow_timer.timeout.connect(self._on_change_glow_timeout)
	for child in get_children():
		if child is Button:
			child.desired_state = menu
			child["theme_override_styles/focus"] = button_glow
			children.append(child)
			child.pressed.connect(self.on_button_pressed.bind(child))
			child.focus_entered.connect(self.on_focused.bind(child))

func _process(delta: float) -> void:
	if state_machine.current_state == menu:
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
	for child in children:
		button_glow.bg_color = Color(glow_intensity, 0, 0)
