extends GridContainer

@export var button_glow: StyleBoxFlat
@export var sound: PolyphonicMenuAudio
@export var menu: MenuState
@export var state_machine: MenuStateMachine
var children: Array[Button]

func _ready() -> void:
	for child in get_children():
		if child is Button:
			child.desired_state = menu
			child["theme_override_styles/focus"] = button_glow
			children.append(child)
			child.pressed.connect(self.on_button_pressed.bind(child))
			child.focus_entered.connect(self.on_focused.bind(child))
