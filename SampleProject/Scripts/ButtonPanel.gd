extends VBoxContainer
class_name InvMenuPanel

@export var button_glow: StyleBoxFlat
@export var glow_timer: Timer
@export var sound: PolyphonicMenuAudio
var min_glow_intensity: float = 0.34
var glow_intensity: float = min_glow_intensity
var max_glow_intensity: float = 0.44
var increasing_glow: int = 1
var children: Array[Button]

func _ready() -> void:
	for child in get_children():
		if child is Button:
			child["theme_override_styles/focus"] = button_glow
			children.append(child)
			child.pressed.connect(self.on_button_pressed.bind(child))
			child.focus_entered.connect(self.on_focused)

func _process(delta: float) -> void:
	print("heh")
	if not $"../../../".resume_game:
		glow_intensity = glow_intensity + 0.1*delta*increasing_glow
		if glow_intensity >= max_glow_intensity:
			increasing_glow = -1
		elif glow_intensity < min_glow_intensity:
			increasing_glow = 1
		if glow_timer.is_stopped():
			glow_timer.start()
	elif not glow_timer.is_stopped():
		glow_timer.stop()
			
func _on_change_glow_timeout() -> void:
	for child in children:
		button_glow.bg_color = Color(glow_intensity, 0, 0)
		
func on_button_pressed(which):
	sound.play_sound_effect_from_library("confirm")
	if which.get_index() == 2:
		$"../../..".animation.play("change")
		$"../../..".equip_menu.animation.play_backwards("change")
	
func on_focused():
	sound.play_sound_effect_from_library("cursor")
