extends GridContainer
class_name LetterBox

const BUTTON_SIZE: Vector2 = Vector2(64, 64)
const BUTTON_MODULATE: Color = Color(1.5, 1.5, 1.5, 1)
const BUTTON_PATH: String = "res://assets/sprites/HUD/NameEntry/"
const BUTTON_EXTENSION: String = ".png"
const BUTTONS: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "@", "Et", "ExclamationMark", "QuestionMark", "Line", "Back", "Ok"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button in BUTTONS:
		var cur_button: Button = Button.new()
		cur_button.focus_mode = Control.FOCUS_NONE
		cur_button.icon = load(BUTTON_PATH + button + BUTTON_EXTENSION)
		cur_button.flat = true
		cur_button.expand_icon = true
		cur_button.custom_minimum_size = BUTTON_SIZE
		cur_button.modulate = BUTTON_MODULATE
		cur_button.clip_text = true
		cur_button.text = button
		add_child(cur_button)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
