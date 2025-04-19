extends MenuState
class_name InvHints
@export var button_glow: StyleBoxFlat
@export var buttons: HintButtons
@export var tutorial_box: VBoxContainer
const MINIMUM_BUTTON_SIZE: Vector2 = Vector2(250, 0)

func enter():
	animation.play_backwards("change")
	updateHintList()
	buttons.setButtons()
	default_button.grab_focus()

func exit():
	deleteHintList()
	animation.play("change")

func Update(delta: float):
	if Input.is_action_just_pressed("ui_cancel"):
		Transitioned.emit(self, "menu")
	
func Physics_Update(delta: float):
	pass
	
func updateHintList() -> void:
	for i in range(0, Global.tutorial_screen.tutorials.size()):
		var button: InventoryButton = InventoryButton.new()
		if Global.player.stats.tutorial_flags[i]:
			button.text = Global.tutorial_screen.tutorials[i].title
			button.disabled = false
		else:
			button.text = "? ? ?"
			button.disabled = true
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size = MINIMUM_BUTTON_SIZE
		button.flat = true
		button.state_machine = buttons.state_machine
		button.desired_state = self
		buttons.add_child(button)
	default_button = buttons.get_child(0)

func deleteHintList() -> void:
	for button in buttons.get_children():
		button.queue_free()

func on_button_pressed(which) -> void:
	sound.play_sound_effect_from_library("denied")
	
func on_focused(which) -> void:
	var current_button_index: int = which.get_index()
	sound.play_sound_effect_from_library("cursor")
	displayCurrentHint(current_button_index, which.disabled)
	
func displayCurrentHint(hint_id: int, hide_hint: bool) -> void:
	var current_tutorial_image: TextureRect = tutorial_box.get_child(0)
	var current_tutorial_description: RichTextLabelWithButtons = tutorial_box.get_child(1)
	var tutorial_to_display: TutorialFormat = Global.tutorial_screen.tutorials[hint_id]
	if hide_hint:
		current_tutorial_image.texture = null
		current_tutorial_description.new_text = ""
		return
	current_tutorial_image.texture = tutorial_to_display.image
	current_tutorial_image.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	var tutorial_text: String = tutorial_to_display.description
	var skip_chars: int = 0
	for i in range(0, tutorial_text.length()-1):
		if skip_chars > 0:
			skip_chars -= 1
			continue
		if tutorial_text[i] == "\n" and tutorial_text[i+1] == "\n":
			tutorial_text[i] = " "
			skip_chars = 1
			continue
		elif tutorial_text[i] == "\n" and tutorial_text[i-1] == ".":
			continue
		elif tutorial_text[i] == "\n":
			tutorial_text[i] = " "
	current_tutorial_description.new_text = tutorial_text
