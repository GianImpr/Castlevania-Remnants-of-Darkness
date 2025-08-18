extends MenuButtons
class_name MenuSaveRoom
@export var animation: AnimationPlayer
@onready var chair_node = get_parent().get_parent().get_parent()
@export var saving_screen: SavingScreen
const stand_up_flag_id: int = 12
const stand_up_hint_time: float = 3
var stand_up_hint_text: String = tr("HINT_12")
var needs_to_choose = true

func _ready() -> void:
	super()
	saving_screen.process_mode = Node.PROCESS_MODE_DISABLED
	chair_node.opened_menu = true

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("circle") and needs_to_choose:
		_exitMenu()

func on_button_pressed(which):
	needs_to_choose = false
	match which.get_index():
		0:
			which.release_focus()
			_saveGame()
		1:
			warp()
		2:
			which.release_focus()
			_exitMenu()
	sound.play_sound_effect_from_library("confirm")

func _saveGame():
	closeWindow()
	await animation.animation_finished
	saving_screen.saved_with_success = false
	saving_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	await saving_screen.finished
	if saving_screen.saved_with_success:
		chair_node.sound.play_sound_effect_from_library("activate")
		chair_node.animation.play("flash")
		await chair_node.animation.animation_finished
		chair_node.detect_hitbox.monitoring = false
		chair_node.can_sit = false
		if not Global.player.stats.hint_flags[stand_up_flag_id]:
			Global.tutorial_box.activate = true
			Global.tutorial_box.time = stand_up_hint_time
			Global.tutorial_box.text = stand_up_hint_text
			Global.player.stats.hint_flags[stand_up_flag_id] = true
	resumeGame()
	
func warp():
	closeWindow()
	await animation.animation_finished
	resumeGame()
	#chair_node.sound.play_sound_effect_from_library("activate")
	chair_node.animation.play("warp_flash")

	
func _exitMenu():
	closeWindow()
	await animation.animation_finished
	resumeGame()
	
	
func closeWindow():
	animation.play_backwards("appear")
	
func resumeGame():
	chair_node.opened_menu = false
	get_parent().get_parent().queue_free()
